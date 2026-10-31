/**
 * Links the portfolio's existing MySQL tables as Directus collections and
 * applies readable field interfaces. Idempotent: safe to re-run.
 *
 * Usage:
 *   DIRECTUS_URL=https://cms.hasanabbassorathiya.tech \
 *   DIRECTUS_TOKEN=<admin static token> \
 *   node scripts/collections.mjs
 */
const API = (process.env.DIRECTUS_URL || 'http://127.0.0.1:8055').replace(/\/+$/, '');
const TOKEN = process.env.DIRECTUS_TOKEN;

if (!TOKEN) {
  console.error('DIRECTUS_TOKEN is required. In Directus: User Directory -> admin -> Token -> generate, then copy it.');
  process.exit(1);
}

async function api(path, init = {}) {
  for (let attempt = 1; ; attempt += 1) {
    try {
      const response = await fetch(`${API}${path}`, {
        ...init,
        signal: AbortSignal.timeout(60_000),
        headers: {
          Authorization: `Bearer ${TOKEN}`,
          'Content-Type': 'application/json',
          ...(init.headers || {}),
        },
      });
      const text = await response.text();
      const body = text ? JSON.parse(text) : null;
      if (!response.ok) {
        const error = new Error(`${init.method || 'GET'} ${path} -> ${response.status}: ${text.slice(0, 400)}`);
        error.status = response.status;
        throw error;
      }
      return body;
    } catch (error) {
      if (attempt >= 3 || error.status) throw error;
      console.warn(`  ~ retrying ${init.method || 'GET'} ${path} (${error.name}: ${error.message})`);
      await new Promise((resolve) => setTimeout(resolve, 2000 * attempt));
    }
  }
}

const collections = [
  {
    collection: 'apps',
    meta: {
      icon: 'apps',
      note: 'Published apps. `published` controls whether the public site shows the app.',
      display_template: '{{name}}',
      sort_field: 'sort_order',
      archive_field: 'published',
      archive_value: 0,
      archive_app_filter: true,
    },
    notes: {
      slug: 'lowercase-with-hyphens, used in /apps/<slug>',
      platforms: '["iOS","Android"]',
      icon: 'Path under /media/apps/... or a full URL',
      screenshots: '["/media/apps/slug/shot1.webp"]',
      stack: '["Flutter","Dart"]',
      links: '{"ios":"https://…","android":"https://…"}',
      metrics: '[["4.9★","Google Play rating"]]',
      features: '["Feature one","Feature two"]',
      seo_title: 'Defaults to the app name. Keep under 60 characters.',
      seo_description: 'Search/social description. 150–160 characters is ideal.',
      aso_subtitle: '30 characters on the App Store listing.',
      aso_keywords: 'Comma-separated; 100 characters max on App Store.',
    },
  },
  {
    collection: 'clients',
    meta: {
      icon: 'domain',
      note: 'Client case studies. `published` controls whether the public site shows the case study.',
      display_template: '{{name}}',
      sort_field: 'sort_order',
      archive_field: 'published',
      archive_value: 0,
      archive_app_filter: true,
    },
    notes: {
      slug: 'used in /work/<slug>',
      what_i_did: '["Led mobile engineering…"]',
      stack: '["Flutter","Riverpod"]',
      facts: '[["Role","Mobile lead"]]',
      logo: 'Path under /media/... or a full URL',
    },
  },
  {
    collection: 'posts',
    meta: {
      icon: 'article',
      note: 'Blog posts. `published` controls whether the public site shows the post.',
      display_template: '{{title}}',
      archive_field: 'published',
      archive_value: 0,
      archive_app_filter: true,
    },
    notes: {
      slug: 'used in /blog/<slug>',
      tags: '["Flutter","Architecture"]',
      body: 'Markdown. Headings, lists, tables and code blocks are supported.',
    },
  },
  {
    collection: 'projects',
    meta: {
      icon: 'work',
      note: 'Portfolio projects.',
      display_template: '{{title}}',
      sort_field: 'sort_order',
    },
    notes: {
      stack: '["Flutter","Riverpod"]',
      store_urls: '{"ios":"…","android":"…"}',
    },
  },
  {
    collection: 'experiences',
    meta: {
      icon: 'timeline',
      note: 'Timeline roles.',
      display_template: '{{company}} — {{position}}',
      sort_field: 'sort_order',
    },
    notes: {
      period: 'e.g. 07/2023 — 01/2026',
      points: '["Owned architecture…","Shipped…"]',
      highlight: 'Older single-line field, still served by the API.',
    },
  },
  {
    collection: 'skills',
    meta: {
      icon: 'star',
      note: 'Skill chips grouped by category.',
      display_template: '{{grp}} · {{name}}',
      sort_field: 'sort_order',
    },
    notes: {
      grp: 'Mobile · AI & automation · Backend & cloud · FinTech & security · Delivery',
    },
  },
  {
    collection: 'testimonials',
    meta: {
      icon: 'format_quote',
      note: 'Only real, attributable quotes. Never add invented testimonials.',
      display_template: '{{author}}',
      sort_field: 'sort_order',
    },
  },
  {
    collection: 'profile',
    meta: {
      icon: 'person',
      note: 'Key/value profile fields used across the site (name, email, socials, hero copy).',
      display_template: '{{k}}',
    },
    notes: {
      k: 'Field key, e.g. name, email, youtube, instagram, medium, certificate',
      v: 'Field value. URLs are expected to be absolute.',
    },
  },
  {
    collection: 'settings',
    meta: {
      icon: 'settings',
      note: 'Growth settings. Empty values are ignored by the public site.',
      display_template: '{{k}}',
    },
    notes: {
      k: 'Setting key',
      v: 'Setting value. Leave empty to keep the feature disabled.',
    },
  },
];

function fieldMeta(name, type, note) {
  const meta = { note: note || null };
  if (['published', 'noindex', 'is_featured'].includes(name)) {
    meta.interface = 'boolean';
    meta.special = ['cast-boolean'];
    meta.options = { label: name === 'published' ? 'Published' : name === 'noindex' ? 'Hide from search engines' : 'Featured' };
    return meta;
  }
  if (name === 'body') {
    meta.interface = 'input-rich-text-md';
    return meta;
  }
  if (['platforms', 'screenshots', 'stack', 'features', 'tags', 'what_i_did', 'points'].includes(name)) {
    meta.interface = 'tags';
    meta.special = ['cast-json'];
    meta.options = { placeholder: note || 'Add an item and press Enter' };
    return meta;
  }
  if (['links', 'metrics', 'facts', 'store_urls'].includes(name)) {
    meta.interface = 'input-code';
    meta.special = ['cast-json'];
    meta.options = { language: 'json', placeholder: note || '{}' };
    return meta;
  }
  if (['summary', 'story', 'challenge', 'outcome', 'description', 'dek', 'quote', 'seo_description', 'aso_promo_text'].includes(name) || type === 'text') {
    meta.interface = 'input-multiline';
    return meta;
  }
  if (name === 'post_date') {
    meta.interface = 'datetime';
    return meta;
  }
  if (['rating_value', 'rating_count', 'minutes'].includes(name)) {
    meta.interface = 'input';
    return meta;
  }
  if (type === 'integer' || type === 'bigInteger' || type === 'float' || type === 'decimal') {
    meta.interface = 'input';
    return meta;
  }
  if (name === 'icon' || name === 'logo' || name === 'seo_image') {
    meta.note = note || 'Path under /media/... or a full URL';
    return meta;
  }
  return meta;
}

async function main() {
  console.log(`Directus: ${API}`);
  const me = await api('/users/me?fields=email,role.name');
  console.log(`Authenticated as ${me.data.email} (${me.data.role?.name || 'no role'})`);

  const only = process.argv.find((arg) => arg.startsWith('--only='))?.slice('--only='.length).split(',');
  const existing = new Set((await api('/collections?limit=-1')).data.map((item) => item.collection));

  for (const def of collections) {
    if (only && !only.includes(def.collection)) continue;
    if (!existing.has(def.collection)) {
      console.error(`\n! Table "${def.collection}" is not visible in Directus. Check that the table exists in the database and the DB user can read it.`);
      continue;
    }

    try {
      // PATCH upserts Directus metadata for a table that already exists in the database.
      await api(`/collections/${def.collection}`, { method: 'PATCH', body: JSON.stringify({ meta: def.meta }) });
    } catch (error) {
      console.warn(`  ~ Could not update collection meta for ${def.collection}: ${error.message}`);
    }

    let fields = [];
    try {
      fields = (await api(`/fields/${def.collection}`)).data;
    } catch (error) {
      console.warn(`  ~ Could not read fields for ${def.collection}: ${error.message}`);
      continue;
    }

    let index = 0;
    for (const field of fields) {
      index += 1;
      if (field.field === 'id' || field.field === 'k') continue;
      const meta = fieldMeta(field.field, field.type, def.notes?.[field.field]);
      meta.sort = index;
      try {
        await api(`/fields/${def.collection}/${encodeURIComponent(field.field)}`, {
          method: 'PATCH',
          body: JSON.stringify({ meta }),
        });
      } catch (error) {
        console.warn(`  ~ ${def.collection}.${field.field}: ${error.message}`);
      }
    }

    console.log(`linked ${def.collection} (${fields.length} fields)`);
  }

  console.log(`\nDone. Open ${API}/admin/content/apps and confirm existing apps are listed and prefilled.`);
}

main().catch((error) => {
  console.error(error.stack || error.message);
  process.exit(1);
});
