-- 2026-11-01 — Postiz -> site activity feed
-- Additive only; safe to re-run. The public read path returns [] until this runs.
CREATE TABLE IF NOT EXISTS social_posts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  external_id VARCHAR(128) NOT NULL,
  provider VARCHAR(40) NOT NULL DEFAULT '',
  channel VARCHAR(120) NOT NULL DEFAULT '',
  kind VARCHAR(24) NOT NULL DEFAULT 'post',
  text VARCHAR(2000) NOT NULL DEFAULT '',
  url VARCHAR(500) NOT NULL DEFAULT '',
  image VARCHAR(500) NOT NULL DEFAULT '',
  posted_at DATETIME NOT NULL,
  published TINYINT(1) NOT NULL DEFAULT 1,
  raw_json MEDIUMTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uniq_social_external (external_id),
  KEY idx_social_feed (published, posted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
