-- Profile corrections, 2026-10-31.
-- Removes the unverified 100K+ cross-client aggregate and the retired {{users}}
-- token, and replaces the stale MERN-first headline and FlowCV resume link.
-- Not applied automatically: run only with owner approval.

DELETE FROM `profile` WHERE `k` = 'users_reached';

INSERT INTO `profile` (`k`, `v`) VALUES
  ('experience_years', '6'),
  ('headline', 'I build Flutter apps and AI systems that survive production'),
  ('resume', 'https://hasanabbassorathiya.tech/hasan-abbas-sorathiya-resume.pdf'),
  ('sub', 'Senior mobile and AI engineer in Dubai. {{years}} years across fintech, mobility, hospitality, and community products — Flutter as my primary stack, iOS and Android delivery, and the AI systems behind the product. Built to keep working after launch.')
ON DUPLICATE KEY UPDATE `v` = VALUES(`v`);

UPDATE `profile`
SET `v` = '[{"label":"Years Experience","value":6,"suffix":"+"},{"label":"App Profiles","value":15},{"label":"Client Engagements","value":3},{"label":"Good2Go Users","value":50,"suffix":"K+"}]'
WHERE `k` = 'stats_json';
