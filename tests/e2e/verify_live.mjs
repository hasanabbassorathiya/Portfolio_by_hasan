import { chromium } from 'playwright-core';
import fs from 'node:fs';
import path from 'node:path';

const TARGET_URL = process.env.TARGET_URL || 'https://hasan-abbas-portfolio.web.app';
const SHOTS_DIR = path.join(path.dirname(new URL(import.meta.url).pathname.replace(/^\/([A-Z]:)/, '$1')), 'shots');
fs.mkdirSync(SHOTS_DIR, { recursive: true });

const DEVICES = [
  { name: 'mobile-iphone13', width: 390, height: 844, dsf: 3, mobile: true },
  { name: 'tablet-ipad', width: 768, height: 1024, dsf: 2, mobile: true },
  { name: 'laptop-1280', width: 1280, height: 800, dsf: 1, mobile: false },
  { name: 'desktop-1920', width: 1920, height: 1080, dsf: 1, mobile: false },
];

const report = { url: TARGET_URL, timestamp: new Date().toISOString(), devices: {} };

function collectAriaLabels(page) {
  return page.evaluate(() => {
    const host = document.querySelector('flt-semantics-host');
    const roots = [host?.shadowRoot, host].filter(Boolean);
    for (const r of roots) {
      const nodes = r.querySelectorAll('flt-semantics');
      if (nodes.length) {
        return Array.from(nodes)
          .map((n) => n.getAttribute('aria-label') || '')
          .filter(Boolean);
      }
    }
    return [];
  });
}

async function enableSemantics(page) {
  // Flutter web exposes a body-level placeholder that must receive a TRUSTED
  // user gesture to build the semantics tree. Use a real Playwright click.
  try {
    const ph = page.locator('flt-semantics-placeholder').first();
    if ((await ph.count()) > 0) {
      await ph.click({ force: true, timeout: 5000 });
      return true;
    }
  } catch {
    /* fall through to evaluate fallback */
  }
  try {
    return await page.evaluate(() => {
      const ph = document.querySelector('body > flt-semantics-placeholder');
      if (!ph) {
        const host = document.querySelector('flt-semantics-host');
        return !!host && host.shadowRoot?.querySelectorAll('flt-semantics').length > 0;
      }
      ph.setAttribute('role', 'button');
      ph.setAttribute('tabindex', '0');
      ph.dispatchEvent(new MouseEvent('click', { bubbles: true, composed: true }));
      ph.focus();
      return true;
    });
  } catch {
    return false;
  }
}

const browser = await chromium.launch({ channel: 'chrome', headless: true });

for (const device of DEVICES) {
  const context = await browser.newContext({
    viewport: { width: device.width, height: device.height },
    deviceScaleFactor: device.dsf,
    isMobile: device.mobile,
    hasTouch: device.mobile,
    userAgent: device.mobile
      ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1'
      : undefined,
  });
  const page = await context.newPage();
  const consoleErrors = [];
  const failedRequests = [];
  page.on('console', (m) => {
    if (m.type() === 'error') consoleErrors.push(m.text().slice(0, 400));
  });
  page.on('pageerror', (e) => consoleErrors.push('PAGEERROR: ' + String(e).slice(0, 400)));
  page.on('requestfailed', (r) => failedRequests.push(`${r.url()} :: ${r.failure()?.errorText ?? '?'}`));

  const dev = {};
  report.devices[device.name] = dev;

  try {
    await page.goto(TARGET_URL, { waitUntil: 'load', timeout: 60000 });
    await page.waitForSelector('flutter-view', { timeout: 45000 });
    await page.waitForTimeout(9000);
    dev.title = await page.title();

    const shot = (n) => path.join(SHOTS_DIR, `${device.name}-${String(n).padStart(2, '0')}.png`);
    await page.screenshot({ path: shot(0) });

    let shots = ['00'];
    for (let i = 1; i <= 14; i++) {
      await page.mouse.wheel(0, Math.round(device.height * 0.82));
      await page.waitForTimeout(1300);
      await page.screenshot({ path: shot(i) });
      shots.push(String(i).padStart(2, '0'));
    }
    dev.scrollShots = shots.length;

    dev.semanticsEnabled = await enableSemantics(page);
    await page.waitForTimeout(3000);

    if (dev.semanticsEnabled) {
      const labels = await collectAriaLabels(page);
      dev.labelCount = labels.length;
      dev.sampleLabels = labels.slice(0, 5);
      dev.sectionChecks = {
        heroCta: labels.some((l) => /VIEW MY WORK|Download CV|VIEW WORK/i.test(l)),
        services: labels.some((l) => /WHAT I DO/i.test(l)),
        projects: labels.some((l) => /Selected projects/i.test(l)),
        testimonials: labels.some((l) => /What they say/i.test(l)),
        blog: labels.some((l) => /Writing|THOUGHTS|blog/i.test(l)),
        contact: labels.some((l) => /build together/i.test(l)),
        footer: labels.some((l) => /ALL RIGHTS RESERVED/i.test(l)),
        emDashLeak: labels.filter((l) => l.includes('\u2014') || l.includes('\u2013')),
      };
    }

    if (!device.mobile) {
      // --- desktop interaction phase ---
      await page.mouse.wheel(0, -40000);
      await page.waitForTimeout(1200);

      // 1. portfolio filter chip
      const chip = page.locator('flt-semantics[aria-label="MOBILE"]').first();
      if ((await chip.count()) > 0) {
        await chip.scrollIntoViewIfNeeded().catch(() => {});
        await page.waitForTimeout(800);
        await chip.click({ force: true });
        dev.filterChipClicked = true;
        await page.waitForTimeout(1200);
        await page.screenshot({ path: path.join(SHOTS_DIR, `${device.name}-int-filter.png`) });
      }

      // 2. contact form validation
      const inputs = page.locator('input');
      const n = await inputs.count();
      dev.inputCount = n;
      if (n >= 3) {
        await inputs.nth(0).scrollIntoViewIfNeeded().catch(() => {});
        await page.waitForTimeout(900);
        await inputs.nth(0).fill('Playwright Tester');
        await inputs.nth(1).fill('not-an-email');
        await inputs.nth(2).fill('Automated layout verification run.');
        const sendBtn = page.locator('flt-semantics[aria-label="Send Message"]').first();
        if ((await sendBtn.count()) > 0) {
          await sendBtn.click({ force: true });
          await page.waitForTimeout(700);
          const labels = await collectAriaLabels(page);
          dev.contactValidationShown = labels.some((l) => l.includes('fill in every field'));
          await page.screenshot({ path: path.join(SHOTS_DIR, `${device.name}-int-contact-error.png`) });
        }
      }

      // 3. newsletter validation
      const subBtn = page.locator('flt-semantics[aria-label="SUBSCRIBE"]').first();
      if ((await subBtn.count()) > 0 && dev.inputCount >= 4) {
        await inputs.nth(dev.inputCount - 1).fill('bad-email');
        await subBtn.scrollIntoViewIfNeeded().catch(() => {});
        await page.waitForTimeout(600);
        await subBtn.click({ force: true });
        await page.waitForTimeout(700);
        const labels = await collectAriaLabels(page);
        dev.newsletterValidationShown = labels.some((l) => l.includes('valid email'));
        await page.screenshot({ path: path.join(SHOTS_DIR, `${device.name}-int-newsletter-error.png`) });
      }

      // 4. project route navigation
      const viewProject = page.locator('flt-semantics[aria-label*="VIEW PROJECT"]').first();
      if ((await viewProject.count()) > 0) {
        await viewProject.scrollIntoViewIfNeeded().catch(() => {});
        await page.waitForTimeout(800);
        await viewProject.click({ force: true });
        await page.waitForTimeout(2500);
        dev.projectRouteNavigated = /\/project\//.test(page.url());
        await page.screenshot({ path: path.join(SHOTS_DIR, `${device.name}-int-project-page.png`) });
      }
    }

    dev.status = 'ok';
  } catch (err) {
    dev.status = 'failed';
    dev.error = String(err).slice(0, 500);
  }

  dev.consoleErrors = [...new Set(consoleErrors)].slice(0, 10);
  dev.failedRequests = [...new Set(failedRequests)].slice(0, 10);
  await context.close();
}

await browser.close();
fs.writeFileSync(path.join(SHOTS_DIR, '..', 'report.json'), JSON.stringify(report, null, 2));

for (const [name, d] of Object.entries(report.devices)) {
  console.log(`\n=== ${name} [${d.status}] ===`);
  console.log(`title: ${d.title}`);
  console.log(`semantics: ${d.semanticsEnabled} | scroll shots: ${d.scrollShots}`);
    if (d.sectionChecks) {
    const fails = Object.entries(d.sectionChecks)
      .filter(([k, v]) => k !== 'emDashLeak' && !v)
      .map(([k]) => k);
    console.log(`sections missing: ${fails.length ? fails.join(', ') : 'none'}`);
    console.log(`dash leaks: ${d.sectionChecks.emDashLeak.length ? JSON.stringify(d.sectionChecks.emDashLeak) : 'none'}`);
  }
  console.log(`labels: ${d.labelCount ?? 'n/a'} | inputs: ${d.inputCount ?? 'n/a'}`);
  if (!d.mobile || true) {
    const inter = ['filterChipClicked', 'contactValidationShown', 'newsletterValidationShown', 'projectRouteNavigated']
      .map((k) => `${k}=${d[k] ?? '-'}`)
      .join(' | ');
    console.log(inter);
  }
  if (d.consoleErrors.length) console.log(`console errors:\n  ${d.consoleErrors.join('\n  ')}`);
  else console.log('console errors: none');
  if (d.failedRequests.length) console.log(`failed requests:\n  ${d.failedRequests.join('\n  ')}`);
}
