-- Seed data — imported AFTER schema.sql via phpMyAdmin. Idempotent-ish (idempotent upserts).
-- Profile (key→value) — drives hero/contact from DB when wired to API.
REPLACE INTO profile (k, v) VALUES
('name', 'Hasan Abbas Sorathiya'),
('headline', 'Flutter / Mobile, Backend & API integrations, and AI / GenAI engineering'),
('location', 'Dubai, UAE'),
('email', 'hasanabbassorathiya12@gmail.com'),
('linkedin', 'https://linkedin.com/in/hasanabbassorathiya'),
('resume', 'https://hasanabbassorathiya.tech/resume'),
('currently_building', 'Carvan-e-Hind v2 — community platform for the trust — and a handful of AI agents in private beta'),
('creed', 'Engineering excellence is not just about code; it is about the impact it creates.'),
('experience_years', '6'),
('stats_json', '[{"label":"Years Experience","value":6,"suffix":"+"},{"label":"App Profiles","value":21},{"label":"Client Engagements","value":3},{"label":"Good2Go Users","value":50,"suffix":"K+"}]');

-- Featured projects
REPLACE INTO projects (slug, title, category, year, client, role, description, stack, store_urls, is_featured, sort_order) VALUES
('duas-and-aamal', 'Duas and Aamal', 'Mobile', '2023', '', 'Creator & maintainer',
 'A curated daily duas & aamal companion with multi-language support, push reminders, and offline content.',
 '["Flutter","Multi-language","Push Notifications"]',
 '{"ios":"https://apps.apple.com/ae/app/duas-and-aamal/id6478907381"}', 1, 1),
('carvan-e-hind', 'Carvan-e-Hind', 'Mobile', '2024—2026', 'Caravan E Hind Trust', 'Creator & maintainer',
 'Community platform for Carvan-e-Hind Trust — media, events and member engagement, built & maintained on Flutter.',
 '["Flutter","Firebase"]',
 '{"ios":"https://apps.apple.com/in/app/carvan-e-hind/id6745079091"}', 1, 2),
('lumio-iptv', 'Lumio TV · IPTV Player', 'Mobile', '2024', '', 'Lead developer',
 'Android TV & mobile IPTV streaming client — EPG, channel management, and resilient playback across iOS, Android, and web.',
 '["Flutter","Streaming","Android TV"]', '{"ios":"https://apps.apple.com/us/app/lumio-tv-iptv-player/id6766064122","android":"https://play.google.com/store/apps/details?id=app.lumio_iptv.com","web":"https://lumiotv.web.app/"}', 1, 3),
('evlab', 'EVLAB', 'Client Work', '2023—2026', 'Chalhoub Group', 'Mobile engineering lead',
 'Flutter + Riverpod clean architecture, Codemagic CI/CD, AI-assisted delivery workflows (-30% production issues).',
 '["Flutter","Riverpod","Codemagic"]', '{}', 1, 4);

-- Experience timeline
REPLACE INTO experiences (company, position, period, location, highlight, sort_order) VALUES
('Chalhoub Group', 'Senior Software Engineer', '07/2023 — 01/2026', 'Dubai, UAE', 'Led EVLAB mobile+web delivery with AI-assisted workflows; -30% production issues.', 1),
('Belong Interactive', 'Senior Software Engineer', '08/2022 — 06/2023', 'Dubai, UAE', 'Nakheel Marinas app; -USD 20K/yr infra costs; 20% platform adoption lift.', 2),
('Masaar', 'Senior Software Engineer', '01/2022 — 08/2022', 'Ajman, UAE', 'iKllix e-commerce redesign; +25% conversion; -40% crash rate.', 3),
('Vervali Systems', 'Team Lead — Mobile', '03/2021 — 11/2021', 'India', 'Led 24 engineers; Urban Ledger; +40% engagement.', 4),
('Beedev Solutions', 'Flutter Developer', '09/2020 — 03/2021', 'Australia (remote)', 'Pool Inspection app 10K+ downloads in 30 days; banking app 50K+ MAU.', 5),
('Kumite 1 League', 'Flutter Developer', '01/2019 — 08/2020', '', 'Flutter web admin panels; Firebase backend; maps integration.', 6);

-- Skills matrix
REPLACE INTO skills (grp, name, sort_order) VALUES
('AI', 'AI Agents', 1), ('AI', 'RAG', 2), ('AI', 'Vector Embeddings', 3), ('AI', 'Prompt Engineering', 4), ('AI', 'n8n Pipelines', 5),
('Full Stack', 'MERN', 10), ('Full Stack', 'Node.js', 11), ('Full Stack', 'React', 12), ('Full Stack', 'MySQL', 13), ('Full Stack', 'PostgreSQL', 14), ('Full Stack', 'Firebase', 15), ('Full Stack', 'Supabase', 16),
('Mobile', 'Flutter', 20), ('Mobile', 'Riverpod', 21), ('Mobile', 'Clean Architecture', 22), ('Mobile', 'Codemagic CI/CD', 23), ('Mobile', 'App Store/Play Compliance', 24);

-- Testimonials
REPLACE INTO testimonials (quote, author, note, sort_order) VALUES
('Engineering excellence is not just about code; it is about the impact it creates.', 'Hasan Abbas Sorathiya', 'personal creed', 1),
('Hasan''s AI-driven workflows cut our production issues by a third while shipping faster than we ever had.', 'Chalhoub EVLAB team', 'colleague', 2);
