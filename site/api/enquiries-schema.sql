-- Additive, manually imported migration. MySQL 8 / MariaDB, InnoDB required.
-- Import into the same database as api/bootstrap.php; never run DDL on requests.
-- All application dates/times are UTC. No automatic enquiry/outbox deletion.
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
