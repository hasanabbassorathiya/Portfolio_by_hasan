import { chromium } from 'playwright-core';
const browser = await chromium.launch({ channel: 'chrome', headless: true });
const page = await browser.newPage({ viewport: { width: 1920, height: 1080 } });
await page.goto('https://hasan-abbas-portfolio.web.app', { waitUntil: 'load' });
await page.waitForSelector('flutter-view', { timeout: 45000 });
await page.waitForTimeout(8000);

function deepCount() {
  const total = { sems: 0 };
  const walk = (root) => {
    for (const el of root.querySelectorAll('*')) {
      if (el.tagName === 'FLT-SEMANTICS') total.sems++;
      if (el.shadowRoot) walk(el.shadowRoot);
    }
  };
  walk(document);
  return total.sems;
}

console.log('before:', await page.evaluate(deepCount));

const box = await page.locator('flt-semantics-placeholder').boundingBox();
console.log('placeholder box:', box);

await page.locator('flt-semantics-placeholder').click({ force: true }).catch(e => console.log('click err:', String(e).slice(0,100)));
await page.waitForTimeout(4000);
console.log('after real click:', await page.evaluate(deepCount));
console.log('placeholder still there:', await page.locator('flt-semantics-placeholder').count());

// try keyboard tab approach
await page.keyboard.press('Tab');
await page.waitForTimeout(2000);
console.log('after Tab:', await page.evaluate(deepCount));

// try focusing placeholder explicitly
await page.evaluate(() => {
  let ph = document.querySelector('body > flt-semantics-placeholder');
  if (!ph) return 'no placeholder';
  ph.setAttribute('tabindex', '0');
  ph.focus();
  return 'focused';
});
await page.waitForTimeout(3000);
console.log('after focus:', await page.evaluate(deepCount));

// inspect host contents
console.log(await page.evaluate(() => {
  const h = document.querySelector('flt-semantics-host');
  return JSON.stringify({ hostExists: !!h, kids: h ? h.children.length : -1, sr: h?.shadowRoot ? h.shadowRoot.children.length : -1 });
}));

await page.screenshot({ path: 'tests/e2e/shots/_probe2.png' });
await browser.close();
