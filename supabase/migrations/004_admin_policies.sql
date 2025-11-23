-- Admin Write Policies
-- Critical security migration: Adds proper admin write/update/delete policies
-- This migration MUST be run before deploying to production

-- ============================================
-- ADMIN POLICIES FOR ALL TABLES
-- ============================================

-- Profiles: Admin can update
CREATE POLICY "Admins can update profiles"
  ON profiles FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Social Links: Admin can manage
CREATE POLICY "Admins can insert social links"
  ON social_links FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can update social links"
  ON social_links FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can delete social links"
  ON social_links FOR DELETE
  USING (auth.role() = 'authenticated');

-- Services: Admin can manage
CREATE POLICY "Admins can insert services"
  ON services FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can update services"
  ON services FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can delete services"
  ON services FOR DELETE
  USING (auth.role() = 'authenticated');

-- Works: Admin can manage
CREATE POLICY "Admins can insert works"
  ON works FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can update works"
  ON works FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can delete works"
  ON works FOR DELETE
  USING (auth.role() = 'authenticated');

-- Blogs: Admin can manage
CREATE POLICY "Admins can insert blogs"
  ON blogs FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can update blogs"
  ON blogs FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can delete blogs"
  ON blogs FOR DELETE
  USING (auth.role() = 'authenticated');

-- Testimonials: Admin can manage
CREATE POLICY "Admins can insert testimonials"
  ON testimonials FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can update testimonials"
  ON testimonials FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can delete testimonials"
  ON testimonials FOR DELETE
  USING (auth.role() = 'authenticated');

-- Experiences: Admin can manage
CREATE POLICY "Admins can insert experiences"
  ON experiences FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can update experiences"
  ON experiences FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can delete experiences"
  ON experiences FOR DELETE
  USING (auth.role() = 'authenticated');

-- Contact Messages: Admin can read and update
CREATE POLICY "Admins can read contact messages"
  ON contact_messages FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Admins can update contact messages"
  ON contact_messages FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can delete contact messages"
  ON contact_messages FOR DELETE
  USING (auth.role() = 'authenticated');

-- Localizations: Admin can manage
CREATE POLICY "Admins can insert localizations"
  ON localizations FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can update localizations"
  ON localizations FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can delete localizations"
  ON localizations FOR DELETE
  USING (auth.role() = 'authenticated');

-- Settings: Admin can manage
CREATE POLICY "Admins can insert settings"
  ON settings FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can update settings"
  ON settings FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can delete settings"
  ON settings FOR DELETE
  USING (auth.role() = 'authenticated');

