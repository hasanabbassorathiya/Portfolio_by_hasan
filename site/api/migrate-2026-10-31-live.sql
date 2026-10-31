-- Live API migration — 2026-10-31
-- Brings the production database up to the schema the current api/ code expects.
-- Additive only: creates missing tables and columns, adds two unique keys when the
-- existing rows allow it, and inserts missing settings defaults without touching
-- values already stored. Safe to run more than once.
--
-- Import through phpMyAdmin (Import tab) or:
--   mysql --defaults-extra-file=... DB_NAME < migrate-2026-10-31-live.sql
-- Never run DDL from a web request.

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------------
-- Growth-platform tables (v2-schema.sql, made idempotent)
-- ---------------------------------------------------------------------------

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

-- Already present on the live database; created here for fresh installs.
CREATE TABLE IF NOT EXISTS subscribers (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(190) NOT NULL UNIQUE,
  source VARCHAR(40) DEFAULT '',
  ip_hash CHAR(64) DEFAULT '',
  unsub_token CHAR(32) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY ip_created (ip_hash, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------------
-- Enquiry intake (enquiries-schema.sql, unchanged)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS enquiry_ip_locks (
  ip_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin PRIMARY KEY
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS enquiries (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  reference CHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL UNIQUE,
  request_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL UNIQUE,
  payload_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  ip_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL,
  type VARCHAR(60) NOT NULL,
  message TEXT NOT NULL,
  consent_at DATETIME NOT NULL,
  consent_version VARCHAR(32) NOT NULL DEFAULT 'enquiry-v1',
  status ENUM('new','contacted','qualified','proposal','won','closed','spam') NOT NULL DEFAULT 'new',
  notes TEXT NOT NULL,
  next_action VARCHAR(255) NOT NULL DEFAULT '',
  follow_up_date DATE NULL,
  version INT UNSIGNED NOT NULL DEFAULT 1,
  updated_by INT UNSIGNED NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  KEY enquiries_status_time (status, created_at, id),
  KEY enquiries_follow_up (follow_up_date, status),
  KEY enquiries_time (created_at, id),
  KEY enquiries_ip_time (ip_hash, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS enquiry_outbox (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  enquiry_id BIGINT UNSIGNED NOT NULL,
  kind ENUM('owner','ack') NOT NULL,
  status ENUM('pending','processing','failed','sent') NOT NULL DEFAULT 'pending',
  attempts SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  total_attempts INT UNSIGNED NOT NULL DEFAULT 0,
  next_attempt_at DATETIME NULL,
  claimed_at DATETIME NULL,
  claim_token CHAR(32) CHARACTER SET ascii COLLATE ascii_bin NULL,
  last_error ENUM('transport_rejected','transport_unavailable','acceptance_unknown') NULL,
  accepted_at DATETIME NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  UNIQUE KEY enquiry_notification (enquiry_id, kind),
  KEY enquiry_outbox_due (status, next_attempt_at, id),
  CONSTRAINT enquiry_outbox_lead FOREIGN KEY (enquiry_id) REFERENCES enquiries(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------------
-- Columns added by v2-schema.sql; added only when absent
-- ---------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS portfolio_add_column;
DELIMITER //
CREATE PROCEDURE portfolio_add_column(IN tbl VARCHAR(64), IN col VARCHAR(64), IN ddl TEXT)
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = tbl AND COLUMN_NAME = col
  ) THEN
    SET @portfolio_ddl = CONCAT('ALTER TABLE `', tbl, '` ADD COLUMN ', ddl);
    PREPARE portfolio_stmt FROM @portfolio_ddl;
    EXECUTE portfolio_stmt;
    DEALLOCATE PREPARE portfolio_stmt;
  END IF;
END//
DELIMITER ;

CALL portfolio_add_column('apps', 'seo_title', '`seo_title` VARCHAR(255) DEFAULT NULL');
CALL portfolio_add_column('apps', 'seo_description', '`seo_description` VARCHAR(320) DEFAULT NULL');
CALL portfolio_add_column('apps', 'seo_image', '`seo_image` VARCHAR(255) DEFAULT NULL');
CALL portfolio_add_column('apps', 'noindex', '`noindex` TINYINT(1) NOT NULL DEFAULT 0');
CALL portfolio_add_column('apps', 'aso_subtitle', '`aso_subtitle` VARCHAR(120) DEFAULT NULL');
CALL portfolio_add_column('apps', 'aso_keywords', '`aso_keywords` VARCHAR(255) DEFAULT NULL');
CALL portfolio_add_column('apps', 'aso_category', '`aso_category` VARCHAR(60) DEFAULT NULL');
CALL portfolio_add_column('apps', 'aso_age_rating', '`aso_age_rating` VARCHAR(20) DEFAULT NULL');
CALL portfolio_add_column('apps', 'aso_promo_text', '`aso_promo_text` VARCHAR(255) DEFAULT NULL');

CALL portfolio_add_column('clients', 'seo_title', '`seo_title` VARCHAR(255) DEFAULT NULL');
CALL portfolio_add_column('clients', 'seo_description', '`seo_description` VARCHAR(320) DEFAULT NULL');
CALL portfolio_add_column('clients', 'seo_image', '`seo_image` VARCHAR(255) DEFAULT NULL');
CALL portfolio_add_column('clients', 'noindex', '`noindex` TINYINT(1) NOT NULL DEFAULT 0');

CALL portfolio_add_column('posts', 'seo_title', '`seo_title` VARCHAR(255) DEFAULT NULL');
CALL portfolio_add_column('posts', 'seo_description', '`seo_description` VARCHAR(320) DEFAULT NULL');
CALL portfolio_add_column('posts', 'seo_image', '`seo_image` VARCHAR(255) DEFAULT NULL');
CALL portfolio_add_column('posts', 'noindex', '`noindex` TINYINT(1) NOT NULL DEFAULT 0');

-- Already present live; kept for fresh installs.
CALL portfolio_add_column('experiences', 'summary', '`summary` TEXT DEFAULT NULL');
CALL portfolio_add_column('experiences', 'points', '`points` JSON DEFAULT NULL');

DROP PROCEDURE IF EXISTS portfolio_add_column;

-- ---------------------------------------------------------------------------
-- Unique keys from v2-schema.sql, only when no duplicate rows block them
-- ---------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS portfolio_add_unique;
DELIMITER //
CREATE PROCEDURE portfolio_add_unique(IN tbl VARCHAR(64), IN idx VARCHAR(64), IN cols TEXT)
BEGIN
  DECLARE duplicate_rows INT DEFAULT 0;
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = tbl AND INDEX_NAME = idx
  ) THEN
    SET @portfolio_count = CONCAT(
      'SELECT COUNT(*) INTO @portfolio_duplicates FROM (SELECT 1 FROM `', tbl,
      '` GROUP BY ', cols, ' HAVING COUNT(*) > 1 LIMIT 1) portfolio_dup');
    PREPARE portfolio_stmt FROM @portfolio_count;
    EXECUTE portfolio_stmt;
    DEALLOCATE PREPARE portfolio_stmt;
    SET duplicate_rows = COALESCE(@portfolio_duplicates, 0);
    IF duplicate_rows = 0 THEN
      SET @portfolio_ddl = CONCAT('ALTER TABLE `', tbl, '` ADD UNIQUE KEY `', idx, '` (', cols, ')');
      PREPARE portfolio_stmt FROM @portfolio_ddl;
      EXECUTE portfolio_stmt;
      DEALLOCATE PREPARE portfolio_stmt;
    END IF;
  END IF;
END//
DELIMITER ;

CALL portfolio_add_unique('experiences', 'uq_experience', '`company`, `position`');
CALL portfolio_add_unique('skills', 'uq_skill', '`grp`, `name`');

DROP PROCEDURE IF EXISTS portfolio_add_unique;
