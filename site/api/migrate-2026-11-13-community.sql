-- 2026-11-13: community signup captures name, optional WhatsApp and explicit consent.
-- Run once on live (phpMyAdmin or CLI). Fresh installs get these columns from schema.sql.
ALTER TABLE subscribers
  ADD COLUMN name VARCHAR(120) NOT NULL DEFAULT '' AFTER email,
  ADD COLUMN whatsapp VARCHAR(32) NOT NULL DEFAULT '' AFTER name,
  ADD COLUMN consent_at DATETIME NULL AFTER source,
  ADD COLUMN consent_version VARCHAR(32) NOT NULL DEFAULT '' AFTER consent_at;