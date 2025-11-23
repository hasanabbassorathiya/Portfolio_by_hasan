-- Seed Data for Portfolio CMS
-- This file contains initial seed data for development/testing

-- Insert default profile
INSERT INTO profiles (id, name, title, bio, email, phone, location, avatar_url)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'Hasan Abbas Sorathiya',
  'Software Engineer based in UAE',
  'Hello there! My name is Hasan Abbas Sorathiya. I am a web designer & developer, and I''m very passionate and dedicated to my work.',
  'hasanabbassorathiya12@gmail.com',
  '+971 58 960 2320',
  'Dubai, UAE',
  NULL
) ON CONFLICT DO NOTHING;

-- Insert social links
INSERT INTO social_links (profile_id, platform, url, order_index)
VALUES
  ('00000000-0000-0000-0000-000000000001', 'facebook', 'https://facebook.com', 1),
  ('00000000-0000-0000-0000-000000000001', 'twitter', 'https://twitter.com', 2),
  ('00000000-0000-0000-0000-000000000001', 'instagram', 'https://instagram.com', 3),
  ('00000000-0000-0000-0000-000000000001', 'linkedin', 'https://linkedin.com', 4)
ON CONFLICT DO NOTHING;

-- Insert services
INSERT INTO services (title, description, order_index, is_active)
VALUES
  ('Web Design', 'You can customize a template or make your own from scratch, with an immersive library at your disposal.', 1, true),
  ('UI/UX Design', 'You can customize a template or make your own from scratch, with an immersive library at your disposal.', 2, true),
  ('User research', 'You can customize a template or make your own from scratch, with an immersive library at your disposal.', 3, true),
  ('Mobile Application', 'You can customize a template or make your own from scratch, with an immersive library at your disposal.', 4, true)
ON CONFLICT DO NOTHING;

-- Insert experiences
INSERT INTO experiences (company, position, description, start_date, end_date, is_current, order_index)
VALUES
  ('Rolling Thunder', 'Lead UI/UX Designer', NULL, '2018-01-01', NULL, true, 1),
  ('Locost Accessories', 'Senior UI/UX Designer', NULL, '2010-01-01', '2018-12-31', false, 2),
  ('Sagebrush', 'Junior UI/UX Designer', NULL, '2006-01-01', '2008-12-31', false, 3)
ON CONFLICT DO NOTHING;

-- Insert testimonials
INSERT INTO testimonials (client_name, client_role, client_company, quote, rating, order_index, is_active)
VALUES
  ('Larry Diamond', 'Chief Executive Officer', 'Besnik', 'File storage made easy – including powerful features you won''t find anywhere else. Whether you''re.', 5, 1, true)
ON CONFLICT DO NOTHING;

-- Insert settings
INSERT INTO settings (key, value, description)
VALUES
  ('default_language', '"en"', 'Default language for the portfolio'),
  ('supported_languages', '["en", "ar", "fr"]', 'List of supported languages'),
  ('site_title', '"Hasan Abbas Sorathiya - Portfolio"', 'Site title'),
  ('meta_description', '"Portfolio website of Hasan Abbas Sorathiya"', 'Meta description for SEO')
ON CONFLICT (key) DO NOTHING;

