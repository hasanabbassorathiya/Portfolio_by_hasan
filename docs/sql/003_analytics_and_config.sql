-- Analytics and Remote Config Tables
-- Migration for analytics tracking and remote configuration

-- ============================================
-- PAGE VIEWS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS page_views (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  page_path TEXT NOT NULL,
  page_title TEXT,
  user_id UUID,
  session_id TEXT,
  referrer TEXT,
  user_agent TEXT,
  ip_address TEXT,
  additional_data JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_page_views_path ON page_views(page_path);
CREATE INDEX IF NOT EXISTS idx_page_views_created_at ON page_views(created_at);
CREATE INDEX IF NOT EXISTS idx_page_views_user_id ON page_views(user_id);

-- ============================================
-- CUSTOM EVENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS custom_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_name TEXT NOT NULL,
  event_data JSONB,
  user_id UUID,
  session_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_custom_events_name ON custom_events(event_name);
CREATE INDEX IF NOT EXISTS idx_custom_events_created_at ON custom_events(created_at);
CREATE INDEX IF NOT EXISTS idx_custom_events_user_id ON custom_events(user_id);

-- ============================================
-- REMOTE CONFIG TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS remote_config (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL,
  description TEXT,
  updated_by UUID REFERENCES auth.users(id),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- ANALYTICS SUMMARY TABLE (Materialized View)
-- ============================================
CREATE TABLE IF NOT EXISTS analytics_summary (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE NOT NULL,
  page_path TEXT,
  view_count INTEGER DEFAULT 0,
  unique_visitors INTEGER DEFAULT 0,
  avg_time_on_page INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(date, page_path)
);

CREATE INDEX IF NOT EXISTS idx_analytics_summary_date ON analytics_summary(date);
CREATE INDEX IF NOT EXISTS idx_analytics_summary_path ON analytics_summary(page_path);

-- ============================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================

-- Enable RLS
ALTER TABLE page_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE remote_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_summary ENABLE ROW LEVEL SECURITY;

-- Page views: Public insert, admin read
CREATE POLICY "Anyone can insert page views"
  ON page_views FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Admins can read page views"
  ON page_views FOR SELECT
  USING (auth.role() = 'authenticated');

-- Custom events: Public insert, admin read
CREATE POLICY "Anyone can insert custom events"
  ON custom_events FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Admins can read custom events"
  ON custom_events FOR SELECT
  USING (auth.role() = 'authenticated');

-- Remote config: Public read, admin write
CREATE POLICY "Anyone can read remote config"
  ON remote_config FOR SELECT
  USING (true);

CREATE POLICY "Admins can manage remote config"
  ON remote_config FOR ALL
  USING (auth.role() = 'authenticated');

-- Analytics summary: Admin only
CREATE POLICY "Admins can read analytics summary"
  ON analytics_summary FOR SELECT
  USING (auth.role() = 'authenticated');

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to update analytics summary
CREATE OR REPLACE FUNCTION update_analytics_summary()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO analytics_summary (date, page_path, view_count)
  VALUES (CURRENT_DATE, NEW.page_path, 1)
  ON CONFLICT (date, page_path)
  DO UPDATE SET view_count = analytics_summary.view_count + 1;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update summary
CREATE TRIGGER trigger_update_analytics_summary
  AFTER INSERT ON page_views
  FOR EACH ROW
  EXECUTE FUNCTION update_analytics_summary();

