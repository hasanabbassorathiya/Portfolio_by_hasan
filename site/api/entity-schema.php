<?php
declare(strict_types=1);

/**
 * Single source of truth for CMS entities.
 * Used by api/crud.php (whitelists + validation) and admin/edit.php (forms).
 *
 * Field keys: name, label, type, required, group, help, options, max, shape.
 * Types: text, textarea, markdown, number, date, checkbox, json, select, image.
 * JSON shapes: list (array of strings), pairs (array of [label, value]), object.
 */
function entity_schema(): array
{
    static $schema = null;
    if ($schema !== null) return $schema;

    $seo = [
        ['name' => 'seo_title', 'label' => 'SEO title', 'type' => 'text', 'group' => 'SEO', 'max' => 255,
         'help' => 'Defaults to the item title. Keep under 60 characters.'],
        ['name' => 'seo_description', 'label' => 'SEO description', 'type' => 'textarea', 'group' => 'SEO', 'max' => 320,
         'help' => 'Search/social description. 150–160 characters is ideal.'],
        ['name' => 'seo_image', 'label' => 'Social image', 'type' => 'image', 'group' => 'SEO',
         'help' => '1200×630. Falls back to /og.png.'],
        ['name' => 'noindex', 'label' => 'Hide from search engines', 'type' => 'checkbox', 'group' => 'SEO'],
    ];

    $published = ['name' => 'published', 'label' => 'Published', 'type' => 'checkbox'];
    $order = ['name' => 'sort_order', 'label' => 'Sort order', 'type' => 'number'];

    $schema = [
        'apps' => [
            'label' => 'Apps',
            'singular' => 'App',
            'table' => 'apps',
            'view' => '../apps/%s',
            'published' => true,
            'order' => 'sort_order',
            'slug' => true,
            'list' => ['name', 'genre', 'year', 'rating_value', 'sort_order'],
            'fields' => [
                ['name' => 'slug', 'label' => 'Slug', 'type' => 'text', 'required' => true, 'help' => 'lowercase-with-hyphens, used in /apps/<slug>'],
                ['name' => 'name', 'label' => 'Name', 'type' => 'text', 'required' => true],
                ['name' => 'tagline', 'label' => 'Tagline', 'type' => 'text', 'required' => true],
                ['name' => 'role', 'label' => 'Role', 'type' => 'text'],
                ['name' => 'year', 'label' => 'Year', 'type' => 'text'],
                ['name' => 'genre', 'label' => 'Genre', 'type' => 'text'],
                ['name' => 'platforms', 'label' => 'Platforms', 'type' => 'json', 'shape' => 'list', 'help' => '["iOS","Android"]'],
                ['name' => 'icon', 'label' => 'Icon', 'type' => 'image', 'help' => '512×512 WebP'],
                ['name' => 'screenshots', 'label' => 'Screenshots', 'type' => 'json', 'shape' => 'list', 'help' => '["/media/apps/slug/shot1.webp"]'],
                ['name' => 'rating_value', 'label' => 'Rating value', 'type' => 'number'],
                ['name' => 'rating_count', 'label' => 'Rating count', 'type' => 'number'],
                ['name' => 'stack', 'label' => 'Stack', 'type' => 'json', 'shape' => 'list', 'help' => '["Flutter","Dart"]'],
                ['name' => 'links', 'label' => 'Store links', 'type' => 'json', 'shape' => 'object', 'help' => '{"ios":"https://…","android":"https://…"}'],
                ['name' => 'metrics', 'label' => 'Metrics', 'type' => 'json', 'shape' => 'pairs', 'help' => '[["4.9★","Google Play rating"]]'],
                ['name' => 'features', 'label' => 'Features', 'type' => 'json', 'shape' => 'list', 'help' => '["Feature one","Feature two"]'],
                ['name' => 'summary', 'label' => 'Summary', 'type' => 'textarea'],
                ['name' => 'story', 'label' => 'Story', 'type' => 'textarea'],
                $published,
                $order,
            ],
            'seo' => true,
            'aso' => true,
        ],
        'clients' => [
            'label' => 'Clients',
            'singular' => 'Client',
            'table' => 'clients',
            'view' => '../work/%s',
            'published' => true,
            'order' => 'sort_order',
            'slug' => true,
            'list' => ['name', 'kicker', 'period', 'metric', 'sort_order'],
            'fields' => [
                ['name' => 'slug', 'label' => 'Slug', 'type' => 'text', 'required' => true, 'help' => 'used in /work/<slug>'],
                ['name' => 'name', 'label' => 'Client', 'type' => 'text', 'required' => true],
                ['name' => 'kicker', 'label' => 'Kicker', 'type' => 'text'],
                ['name' => 'type', 'label' => 'Type', 'type' => 'text'],
                ['name' => 'role', 'label' => 'Role', 'type' => 'text'],
                ['name' => 'period', 'label' => 'Period', 'type' => 'text'],
                ['name' => 'location', 'label' => 'Location', 'type' => 'text'],
                ['name' => 'website', 'label' => 'Website', 'type' => 'text'],
                ['name' => 'logo', 'label' => 'Logo', 'type' => 'image'],
                ['name' => 'metric', 'label' => 'Headline metric', 'type' => 'text'],
                ['name' => 'metric_label', 'label' => 'Metric label', 'type' => 'text'],
                ['name' => 'what_i_did', 'label' => 'What I did', 'type' => 'json', 'shape' => 'list', 'help' => '["Led mobile engineering…"]'],
                ['name' => 'stack', 'label' => 'Stack', 'type' => 'json', 'shape' => 'list', 'help' => '["Flutter","Riverpod"]'],
                ['name' => 'facts', 'label' => 'Facts', 'type' => 'json', 'shape' => 'pairs', 'help' => '[["Role","Mobile lead"]]'],
                ['name' => 'summary', 'label' => 'Summary', 'type' => 'textarea'],
                ['name' => 'challenge', 'label' => 'Challenge', 'type' => 'textarea'],
                ['name' => 'outcome', 'label' => 'Outcome', 'type' => 'textarea'],
                ['name' => 'store_url', 'label' => 'Store URL', 'type' => 'text'],
                $published,
                $order,
            ],
            'seo' => true,
        ],
        'posts' => [
            'label' => 'Posts',
            'singular' => 'Post',
            'table' => 'posts',
            'view' => '../blog/%s',
            'published' => true,
            'slug' => true,
            'list' => ['title', 'post_date', 'category', 'minutes', 'published'],
            'fields' => [
                ['name' => 'slug', 'label' => 'Slug', 'type' => 'text', 'required' => true, 'help' => 'used in /blog/<slug>'],
                ['name' => 'title', 'label' => 'Title', 'type' => 'text', 'required' => true],
                ['name' => 'dek', 'label' => 'Dek', 'type' => 'textarea'],
                ['name' => 'post_date', 'label' => 'Publish date', 'type' => 'date'],
                ['name' => 'category', 'label' => 'Category', 'type' => 'text'],
                ['name' => 'tags', 'label' => 'Tags', 'type' => 'json', 'shape' => 'list', 'help' => '["Flutter","Architecture"]'],
                ['name' => 'minutes', 'label' => 'Read minutes', 'type' => 'number'],
                ['name' => 'body', 'label' => 'Body (Markdown)', 'type' => 'markdown', 'max' => 200000],
                $published,
            ],
            'seo' => true,
        ],
        'projects' => [
            'label' => 'Projects',
            'singular' => 'Project',
            'table' => 'projects',
            'order' => 'sort_order',
            'slug' => true,
            'list' => ['title', 'category', 'year', 'is_featured', 'sort_order'],
            'fields' => [
                ['name' => 'slug', 'label' => 'Slug', 'type' => 'text', 'required' => true],
                ['name' => 'title', 'label' => 'Title', 'type' => 'text', 'required' => true],
                ['name' => 'category', 'label' => 'Category', 'type' => 'text'],
                ['name' => 'year', 'label' => 'Year', 'type' => 'text'],
                ['name' => 'client', 'label' => 'Client', 'type' => 'text'],
                ['name' => 'role', 'label' => 'Role', 'type' => 'text'],
                ['name' => 'description', 'label' => 'Description', 'type' => 'textarea'],
                ['name' => 'stack', 'label' => 'Stack', 'type' => 'json', 'shape' => 'list', 'help' => '["Flutter","Riverpod"]'],
                ['name' => 'store_urls', 'label' => 'Store URLs', 'type' => 'json', 'shape' => 'object', 'help' => '{"ios":"…","android":"…"}'],
                ['name' => 'is_featured', 'label' => 'Featured', 'type' => 'checkbox'],
                $order,
            ],
        ],
        'experiences' => [
            'label' => 'Experience',
            'singular' => 'Role',
            'table' => 'experiences',
            'order' => 'sort_order',
            'list' => ['company', 'position', 'period', 'location', 'sort_order'],
            'fields' => [
                ['name' => 'company', 'label' => 'Company', 'type' => 'text', 'required' => true],
                ['name' => 'position', 'label' => 'Position', 'type' => 'text', 'required' => true],
                ['name' => 'period', 'label' => 'Period', 'type' => 'text', 'required' => true, 'help' => 'e.g. 07/2023 — 01/2026'],
                ['name' => 'location', 'label' => 'Location', 'type' => 'text'],
                ['name' => 'summary', 'label' => 'Summary', 'type' => 'textarea', 'help' => 'One or two lines shown under the role.'],
                ['name' => 'points', 'label' => 'Highlights', 'type' => 'json', 'shape' => 'list', 'help' => '["Owned architecture…","Shipped…"]'],
                ['name' => 'highlight', 'label' => 'Legacy highlight', 'type' => 'text', 'help' => 'Older single-line field, still served by the API.'],
                $order,
            ],
        ],
        'skills' => [
            'label' => 'Skills',
            'singular' => 'Skill',
            'table' => 'skills',
            'order' => 'sort_order',
            'list' => ['grp', 'name', 'sort_order'],
            'fields' => [
                ['name' => 'grp', 'label' => 'Group', 'type' => 'text', 'required' => true, 'help' => 'Mobile · AI & automation · Backend & cloud · FinTech & security · Delivery'],
                ['name' => 'name', 'label' => 'Skill', 'type' => 'text', 'required' => true],
                $order,
            ],
        ],
        'testimonials' => [
            'label' => 'Testimonials',
            'singular' => 'Testimonial',
            'table' => 'testimonials',
            'order' => 'sort_order',
            'list' => ['author', 'note', 'quote', 'sort_order'],
            'fields' => [
                ['name' => 'quote', 'label' => 'Quote', 'type' => 'textarea', 'required' => true],
                ['name' => 'author', 'label' => 'Author', 'type' => 'text', 'required' => true],
                ['name' => 'note', 'label' => 'Author note', 'type' => 'text', 'help' => 'Role and company'],
                $order,
            ],
        ],
        'profile' => [
            'label' => 'Profile',
            'singular' => 'Profile field',
            'table' => 'profile',
            'kv' => true,
            'list' => ['k', 'v'],
            'fields' => [],
        ],
    ];

    foreach ($schema as $key => &$cfg) {
        if (!empty($cfg['seo'])) {
            foreach ($seo as $field) $cfg['fields'][] = $field;
        }
        if (!empty($cfg['aso'])) {
            foreach ([
                ['name' => 'aso_subtitle', 'label' => 'App Store subtitle', 'type' => 'text', 'group' => 'ASO', 'max' => 120, 'help' => '30 characters on the App Store listing.'],
                ['name' => 'aso_keywords', 'label' => 'Keywords', 'type' => 'textarea', 'group' => 'ASO', 'max' => 255, 'help' => 'Comma-separated; 100 characters max on App Store.'],
                ['name' => 'aso_category', 'label' => 'Store category', 'type' => 'text', 'group' => 'ASO', 'max' => 60],
                ['name' => 'aso_age_rating', 'label' => 'Age rating', 'type' => 'text', 'group' => 'ASO', 'max' => 20],
                ['name' => 'aso_promo_text', 'label' => 'Promotional text', 'type' => 'textarea', 'group' => 'ASO', 'max' => 255],
            ] as $field) $cfg['fields'][] = $field;
        }
    }
    unset($cfg);

    return $schema;
}

function entity_resolve(string $name): ?array
{
    $schema = entity_schema();
    if ($name === 'experience') $name = 'experiences';
    if (!isset($schema[$name])) return null;
    return [$name, $schema[$name]];
}

/**
 * Typed definitions for the profile key/value store.
 *
 * The profile entity writes arbitrary k/v rows, so its CRUD whitelist is empty. These
 * definitions describe the keys the public site actually hydrates (content-mappers.js
 * maps each row's `k` straight onto the profile object), letting the panel, MCP tools
 * and Postman render typed controls instead of a free-text key box. `sub` is the hero
 * sub-copy read by hero.jsx / ref-hero.jsx; experience_years is the owner-confirmed
 * figure that drives {{years}} and must stay numeric so dates cannot round it up.
 *
 * @return array<int,array<string,mixed>>
 */
function profile_fields(): array
{
    return [
        ['name' => 'name', 'label' => 'Name', 'type' => 'text', 'group' => 'Identity', 'required' => true, 'max' => 120],
        ['name' => 'role', 'label' => 'Role', 'type' => 'text', 'group' => 'Identity', 'max' => 120],
        ['name' => 'headline', 'label' => 'Headline (h1)', 'type' => 'text', 'group' => 'Identity', 'max' => 200],
        ['name' => 'kicker', 'label' => 'Kicker', 'type' => 'text', 'group' => 'Identity', 'max' => 160],
        ['name' => 'caption', 'label' => 'Caption', 'type' => 'text', 'group' => 'Identity', 'max' => 120],
        ['name' => 'sub', 'label' => 'Hero sub-copy', 'type' => 'textarea', 'group' => 'Hero', 'max' => 2000,
         'help' => 'Tokens resolve from live data: {{years}}, {{apps}}, {{public_links}}, {{clients}}, {{platforms}}.'],
        ['name' => 'experience_years', 'label' => 'Years of experience', 'type' => 'number', 'group' => 'Hero',
         'help' => 'Owner-confirmed figure. Drives {{years}}; kept numeric so experience dates cannot round it up.'],
        ['name' => 'availability', 'label' => 'Availability', 'type' => 'text', 'group' => 'Hero', 'max' => 120],
        ['name' => 'availability_detail', 'label' => 'Availability detail', 'type' => 'text', 'group' => 'Hero', 'max' => 160],
        ['name' => 'open_to', 'label' => 'Open to', 'type' => 'text', 'group' => 'Hero', 'max' => 200],
        ['name' => 'location', 'label' => 'Location', 'type' => 'text', 'group' => 'Contact', 'max' => 120],
        ['name' => 'phone', 'label' => 'Phone', 'type' => 'text', 'group' => 'Contact', 'max' => 40],
        ['name' => 'email', 'label' => 'Email', 'type' => 'text', 'group' => 'Contact', 'max' => 190],
        ['name' => 'resume', 'label' => 'Resume URL', 'type' => 'text', 'group' => 'Contact', 'max' => 255],
        ['name' => 'linkedin', 'label' => 'LinkedIn', 'type' => 'text', 'group' => 'Social', 'max' => 255],
        ['name' => 'github', 'label' => 'GitHub', 'type' => 'text', 'group' => 'Social', 'max' => 255],
        ['name' => 'youtube', 'label' => 'YouTube', 'type' => 'text', 'group' => 'Social', 'max' => 255],
        ['name' => 'instagram', 'label' => 'Instagram', 'type' => 'text', 'group' => 'Social', 'max' => 255],
        ['name' => 'medium', 'label' => 'Medium', 'type' => 'text', 'group' => 'Social', 'max' => 255],
        ['name' => 'buymeacoffee', 'label' => 'Buy Me a Coffee', 'type' => 'text', 'group' => 'Social', 'max' => 255],
        ['name' => 'certificate', 'label' => 'Certificate URL', 'type' => 'text', 'group' => 'Social', 'max' => 500],
        ['name' => 'footnote', 'label' => 'Footnote', 'type' => 'text', 'group' => 'About', 'max' => 200],
        ['name' => 'education', 'label' => 'Education', 'type' => 'text', 'group' => 'About', 'max' => 200],
        ['name' => 'currently_building', 'label' => 'Currently building', 'type' => 'textarea', 'group' => 'About', 'max' => 2000],
        ['name' => 'creed', 'label' => 'Creed', 'type' => 'textarea', 'group' => 'About', 'max' => 2000],
        ['name' => 'stats_json', 'label' => 'Stats', 'type' => 'json', 'shape' => 'list', 'group' => 'About',
         'help' => '[{"label":"Years Experience","value":6,"suffix":"+"}]'],
    ];
}
