-- Growth platform migration — run once on an existing install.
-- Safe to re-run the CREATE TABLE statements; the ALTERs are one-time.

CREATE TABLE IF NOT EXISTS settings (
  k VARCHAR(60) PRIMARY KEY,
  v TEXT,
  is_public TINYINT(1) NOT NULL DEFAULT 0,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO settings (k, v, is_public) VALUES
  ('ga4_id', '', 1),
  ('gsc_verification', '', 1),
  ('indexnow_key', '', 1),
  ('calcom_url', '', 1),
  ('discord_invite', '', 1),
  ('community_enabled', '1', 1),
  ('announcement', '', 1),
  ('default_og_image', '', 1),
  ('linkedin_url', '', 1),
  ('github_url', '', 1),
  ('x_url', '', 1),
  ('instagram_url', '', 1),
  ('play_dev_url', '', 1),
  ('appstore_dev_url', '', 1),
  ('contact_email', '', 1)
ON DUPLICATE KEY UPDATE k = VALUES(k);

CREATE TABLE IF NOT EXISTS media (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  path VARCHAR(255) NOT NULL UNIQUE,
  folder VARCHAR(60) NOT NULL,
  mime VARCHAR(60) NOT NULL,
  bytes INT UNSIGNED NOT NULL DEFAULT 0,
  width INT UNSIGNED NOT NULL DEFAULT 0,
  height INT UNSIGNED NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY folder_created (folder, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS analytics_events (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  ts DATETIME(3) NOT NULL,
  day DATE NOT NULL,
  visitor CHAR(32) NOT NULL,
  session CHAR(32) NOT NULL,
  path VARCHAR(255) NOT NULL,
  event VARCHAR(40) NOT NULL,
  referrer_host VARCHAR(120) NOT NULL DEFAULT '',
  utm JSON NULL,
  device VARCHAR(12) NOT NULL DEFAULT '',
  browser VARCHAR(24) NOT NULL DEFAULT '',
  os VARCHAR(24) NOT NULL DEFAULT '',
  country CHAR(2) NOT NULL DEFAULT '',
  props JSON NULL,
  KEY day_event (day, event),
  KEY day_path (day, path),
  KEY visitor_day (visitor, day)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS analytics_daily (
  day DATE NOT NULL,
  path VARCHAR(180) NOT NULL,
  event VARCHAR(40) NOT NULL,
  device VARCHAR(12) NOT NULL DEFAULT '',
  events INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (day, path, event, device)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE apps
  ADD COLUMN seo_title VARCHAR(255) DEFAULT NULL,
  ADD COLUMN seo_description VARCHAR(320) DEFAULT NULL,
  ADD COLUMN seo_image VARCHAR(255) DEFAULT NULL,
  ADD COLUMN noindex TINYINT(1) NOT NULL DEFAULT 0,
  ADD COLUMN aso_subtitle VARCHAR(120) DEFAULT NULL,
  ADD COLUMN aso_keywords VARCHAR(255) DEFAULT NULL,
  ADD COLUMN aso_category VARCHAR(60) DEFAULT NULL,
  ADD COLUMN aso_age_rating VARCHAR(20) DEFAULT NULL,
  ADD COLUMN aso_promo_text VARCHAR(255) DEFAULT NULL;

ALTER TABLE clients
  ADD COLUMN seo_title VARCHAR(255) DEFAULT NULL,
  ADD COLUMN seo_description VARCHAR(320) DEFAULT NULL,
  ADD COLUMN seo_image VARCHAR(255) DEFAULT NULL,
  ADD COLUMN noindex TINYINT(1) NOT NULL DEFAULT 0;

ALTER TABLE posts
  ADD COLUMN seo_title VARCHAR(255) DEFAULT NULL,
  ADD COLUMN seo_description VARCHAR(320) DEFAULT NULL,
  ADD COLUMN seo_image VARCHAR(255) DEFAULT NULL,
  ADD COLUMN noindex TINYINT(1) NOT NULL DEFAULT 0;

ALTER TABLE experiences
  ADD COLUMN summary TEXT DEFAULT NULL,
  ADD COLUMN points JSON DEFAULT NULL,
  ADD UNIQUE KEY uq_experience (company, position);

ALTER TABLE skills
  ADD UNIQUE KEY uq_skill (grp, name);
