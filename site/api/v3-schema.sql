-- Scoped API tokens — run once on an existing install.
-- Session tokens (auth_tokens) remain full-admin; these are revocable, scoped alternatives.

CREATE TABLE IF NOT EXISTS api_tokens (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  token CHAR(64) NOT NULL UNIQUE,
  admin_id INT UNSIGNED NOT NULL,
  label VARCHAR(120) NOT NULL,
  scopes JSON NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  revoked_at TIMESTAMP NULL DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (admin_id) REFERENCES admins(id) ON DELETE CASCADE,
  KEY admin_revoked (admin_id, revoked_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;