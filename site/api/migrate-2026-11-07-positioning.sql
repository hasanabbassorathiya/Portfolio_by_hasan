-- Positioning line, 2026-11-07.
-- "…that survive production" promised a floor instead of an outcome, and the h1 was hardcoded
-- in ref-hero.jsx while profile.headline sat unused in the database. This makes the CMS row the
-- source of the h1 again. Idempotent: re-running only rewrites these two keys.
--
-- Apply in phpMyAdmin against u124239009_portfolio, or:
--   mysql -u <user> -p <db> < api/migrate-2026-11-07-positioning.sql

INSERT INTO `profile` (`k`, `v`) VALUES
  ('headline', 'I build Flutter apps and AI systems people keep using.'),
  ('sub', 'Senior mobile and AI engineer in Dubai. {{years}} years across fintech, mobility, hospitality, and community products — Flutter as my primary stack, iOS and Android delivery, and the AI systems behind the product. {{apps}} shipped products, {{public_links}} of them public store listings or open source you can open right now.')
ON DUPLICATE KEY UPDATE `v` = VALUES(`v`);
