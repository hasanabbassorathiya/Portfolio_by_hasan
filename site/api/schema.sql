-- Portfolio CMS schema (MySQL 8 / MariaDB compatible) — Hostinger
CREATE TABLE IF NOT EXISTS admins (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,           -- password_hash(), argon2id
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS auth_tokens (
  token CHAR(64) PRIMARY KEY,                    -- random_bytes(32) hex
  admin_id INT UNSIGNED NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  FOREIGN KEY (admin_id) REFERENCES admins(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS login_throttles (
  bucket_key CHAR(64) CHARACTER SET ascii COLLATE ascii_bin PRIMARY KEY,
  attempts INT UNSIGNED NOT NULL DEFAULT 0,
  window_started BIGINT UNSIGNED NOT NULL,
  KEY throttle_window (window_started)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS projects (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  slug VARCHAR(190) NOT NULL UNIQUE,
  title VARCHAR(190) NOT NULL,
  category VARCHAR(60) DEFAULT 'Mobile',
  year VARCHAR(20) DEFAULT '',
  client VARCHAR(120) DEFAULT '',
  role VARCHAR(120) DEFAULT '',
  description TEXT,
  stack JSON,                                     -- ["Flutter","Riverpod"]
  store_urls JSON,                                -- {"ios":"...","android":"..."}
  is_featured TINYINT(1) DEFAULT 0,
  sort_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS experiences (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company VARCHAR(150) NOT NULL,
  position VARCHAR(150) NOT NULL,
  period VARCHAR(40) NOT NULL,
  location VARCHAR(120) DEFAULT '',
  highlight TEXT,                                 -- one distilled line for the timeline
  sort_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS skills (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  grp VARCHAR(40) NOT NULL,                       -- AI | Full Stack | Mobile
  name VARCHAR(80) NOT NULL,
  sort_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS testimonials (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  quote TEXT NOT NULL,
  author VARCHAR(120) NOT NULL,
  note VARCHAR(120) DEFAULT '',
  sort_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS profile (
  k VARCHAR(60) PRIMARY KEY,                      -- name, headline, email, stats_json...
  v TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS clients (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  slug VARCHAR(190) NOT NULL UNIQUE,
  name VARCHAR(190) NOT NULL,
  kicker VARCHAR(190) DEFAULT '',
  type VARCHAR(120) DEFAULT '',
  role VARCHAR(150) DEFAULT '',
  period VARCHAR(60) DEFAULT '',
  location VARCHAR(120) DEFAULT '',
  website VARCHAR(255) DEFAULT '',
  logo VARCHAR(255) DEFAULT '',
  metric VARCHAR(60) DEFAULT '',
  metric_label VARCHAR(120) DEFAULT '',
  summary TEXT,
  challenge TEXT,
  what_i_did JSON,                                -- ["", ""]
  outcome TEXT,
  stack JSON,                                     -- ["Flutter","Riverpod"]
  facts JSON,                                     -- [["Engagement","Jul 2023 — Jan 2026"]]
  store_url VARCHAR(255) DEFAULT '',
  published TINYINT(1) DEFAULT 1,
  sort_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS apps (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  slug VARCHAR(190) NOT NULL UNIQUE,
  name VARCHAR(190) NOT NULL,
  tagline VARCHAR(255) DEFAULT '',
  role VARCHAR(150) DEFAULT '',
  year VARCHAR(40) DEFAULT '',
  platforms JSON,                                 -- ["iOS","Android"]
  genre VARCHAR(80) DEFAULT '',
  icon VARCHAR(255) DEFAULT '',
  screenshots JSON,
  rating_value DECIMAL(2,1) DEFAULT NULL,
  rating_count INT DEFAULT NULL,
  stack JSON,
  links JSON,                                     -- {"ios":"...","android":"..."}
  summary TEXT,
  features JSON,
  story TEXT,
  metrics JSON,                                   -- [["4.6★","App Store rating"]]
  published TINYINT(1) DEFAULT 1,
  sort_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS posts (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  slug VARCHAR(190) NOT NULL UNIQUE,
  title VARCHAR(255) NOT NULL,
  dek TEXT,
  post_date DATE DEFAULT NULL,
  category VARCHAR(80) DEFAULT '',
  tags JSON,
  minutes INT DEFAULT 5,
  body MEDIUMTEXT,
  published TINYINT(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS subscribers (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(190) NOT NULL UNIQUE,
  name VARCHAR(120) NOT NULL DEFAULT '',
  whatsapp VARCHAR(32) NOT NULL DEFAULT '',
  source VARCHAR(40) DEFAULT '',                  -- blog-index | post:<slug> | home-writing | community
  consent_at DATETIME NULL,
  consent_version VARCHAR(32) NOT NULL DEFAULT '',
  ip_hash CHAR(64) DEFAULT '',                    -- sha256(ip + pepper); never the raw IP
  unsub_token CHAR(32) NOT NULL UNIQUE,           -- emailed unsubscribe link
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY ip_created (ip_hash, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
