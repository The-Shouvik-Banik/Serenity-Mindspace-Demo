-- ============================================
-- SERENITY MINDSPACE DATABASE SCHEMA
-- PostgreSQL + Supabase
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable Row Level Security
ALTER DATABASE postgres SET "app.jwt_secret" TO 'your-jwt-secret-here';

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    user_type TEXT NOT NULL CHECK (user_type IN ('user', 'specialist')),
    full_name TEXT NOT NULL,
    phone TEXT,
    date_of_birth DATE,
    profile_photo_url TEXT,
    tokens INTEGER DEFAULT 100,
    last_vault_spin DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster lookups
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_type ON users(user_type);

-- Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Users can only read/update their own data
CREATE POLICY users_select_own ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY users_update_own ON users
    FOR UPDATE USING (auth.uid() = id);

-- ============================================
-- SPECIALISTS TABLE
-- ============================================
CREATE TABLE specialists (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    specialization TEXT[] NOT NULL, -- Array of specializations
    languages TEXT[] NOT NULL,
    experience_years INTEGER NOT NULL,
    bio TEXT,
    education TEXT,
    certifications TEXT[],
    license_number TEXT,
    verification_status TEXT DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected')),
    verification_documents JSONB, -- Store document URLs
    availability JSONB, -- Store weekly availability
    rating DECIMAL(3,2) DEFAULT 0.0,
    total_reviews INTEGER DEFAULT 0,
    total_sessions INTEGER DEFAULT 0,
    hourly_rate_tokens INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for searches
CREATE INDEX idx_specialists_specialization ON specialists USING GIN(specialization);
CREATE INDEX idx_specialists_languages ON specialists USING GIN(languages);
CREATE INDEX idx_specialists_rating ON specialists(rating DESC);
CREATE INDEX idx_specialists_verified ON specialists(verification_status) WHERE verification_status = 'verified';

-- Row Level Security
ALTER TABLE specialists ENABLE ROW LEVEL SECURITY;

-- Anyone can read verified specialists
CREATE POLICY specialists_select_verified ON specialists
    FOR SELECT USING (verification_status = 'verified');

-- Specialists can update their own profile
CREATE POLICY specialists_update_own ON specialists
    FOR UPDATE USING (auth.uid() = id);

-- ============================================
-- ASSESSMENTS TABLE
-- ============================================
CREATE TABLE assessments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    responses JSONB NOT NULL, -- Store all form responses
    sentiment_analysis JSONB, -- ML model results
    risk_score INTEGER, -- 0-100
    risk_level TEXT CHECK (risk_level IN ('low', 'moderate', 'high', 'critical')),
    context_summary TEXT, -- Extracted themes
    recommended_support TEXT CHECK (recommended_support IN ('ai', 'chat_specialist', 'video_specialist')),
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for user's assessments
CREATE INDEX idx_assessments_user ON assessments(user_id, completed_at DESC);
CREATE INDEX idx_assessments_risk ON assessments(risk_level);

-- Row Level Security
ALTER TABLE assessments ENABLE ROW LEVEL SECURITY;

-- Users can only see their own assessments
CREATE POLICY assessments_select_own ON assessments
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own assessments
CREATE POLICY assessments_insert_own ON assessments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Specialists can see assessments of their patients
CREATE POLICY assessments_select_by_specialist ON assessments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM sessions s
            WHERE s.user_id = assessments.user_id
            AND s.specialist_id = auth.uid()
        )
    );

-- ============================================
-- SESSIONS TABLE
-- ============================================
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    specialist_id UUID REFERENCES specialists(id) ON DELETE SET NULL,
    session_type TEXT NOT NULL CHECK (session_type IN ('ai_chat', 'text_chat', 'video_call')),
    status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled', 'no_show')),
    scheduled_at TIMESTAMP WITH TIME ZONE,
    started_at TIMESTAMP WITH TIME ZONE,
    ended_at TIMESTAMP WITH TIME ZONE,
    duration_minutes INTEGER,
    tokens_charged INTEGER NOT NULL,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review TEXT,
    notes TEXT, -- Specialist's private notes
    transcript JSONB, -- Chat messages or summary
    assessment_id UUID REFERENCES assessments(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for queries
CREATE INDEX idx_sessions_user ON sessions(user_id, scheduled_at DESC);
CREATE INDEX idx_sessions_specialist ON sessions(specialist_id, scheduled_at DESC);
CREATE INDEX idx_sessions_status ON sessions(status);
CREATE INDEX idx_sessions_upcoming ON sessions(scheduled_at) WHERE status = 'scheduled';

-- Row Level Security
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;

-- Users can see their own sessions
CREATE POLICY sessions_select_user ON sessions
    FOR SELECT USING (auth.uid() = user_id);

-- Specialists can see their sessions
CREATE POLICY sessions_select_specialist ON sessions
    FOR SELECT USING (auth.uid() = specialist_id);

-- Users can insert sessions
CREATE POLICY sessions_insert_user ON sessions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users and specialists can update their sessions
CREATE POLICY sessions_update_own ON sessions
    FOR UPDATE USING (auth.uid() = user_id OR auth.uid() = specialist_id);

-- ============================================
-- TOKEN TRANSACTIONS TABLE
-- ============================================
CREATE TABLE token_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL, -- Positive for credit, negative for debit
    transaction_type TEXT NOT NULL CHECK (transaction_type IN (
        'signup_bonus', 
        'purchase', 
        'lucky_vault', 
        'session_charge', 
        'tip', 
        'refund',
        'withdrawal'
    )),
    payment_id TEXT, -- Razorpay payment ID
    payment_status TEXT CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),
    reference_id UUID, -- Session ID or purchase ID
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_token_transactions_user ON token_transactions(user_id, created_at DESC);
CREATE INDEX idx_token_transactions_type ON token_transactions(transaction_type);

-- Row Level Security
ALTER TABLE token_transactions ENABLE ROW LEVEL SECURITY;

-- Users can see their own transactions
CREATE POLICY token_transactions_select_own ON token_transactions
    FOR SELECT USING (auth.uid() = user_id);

-- ============================================
-- REVIEWS TABLE
-- ============================================
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE UNIQUE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    specialist_id UUID NOT NULL REFERENCES specialists(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    is_anonymous BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_reviews_specialist ON reviews(specialist_id, created_at DESC);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- Row Level Security
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Anyone can read reviews
CREATE POLICY reviews_select_all ON reviews
    FOR SELECT USING (TRUE);

-- Users can insert their own reviews
CREATE POLICY reviews_insert_own ON reviews
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('appointment', 'reminder', 'token', 'system')),
    read BOOLEAN DEFAULT FALSE,
    action_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_notifications_user ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_unread ON notifications(user_id) WHERE read = FALSE;

-- Row Level Security
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Users can see their own notifications
CREATE POLICY notifications_select_own ON notifications
    FOR SELECT USING (auth.uid() = user_id);

-- Users can update their notifications (mark as read)
CREATE POLICY notifications_update_own ON notifications
    FOR UPDATE USING (auth.uid() = user_id);

-- ============================================
-- CHAT MESSAGES TABLE (for text sessions)
-- ============================================
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message_text TEXT NOT NULL,
    is_system_message BOOLEAN DEFAULT FALSE,
    read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_chat_messages_session ON chat_messages(session_id, created_at);

-- Row Level Security
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Participants can see messages
CREATE POLICY chat_messages_select_participants ON chat_messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM sessions s
            WHERE s.id = chat_messages.session_id
            AND (s.user_id = auth.uid() OR s.specialist_id = auth.uid())
        )
    );

-- Participants can insert messages
CREATE POLICY chat_messages_insert_participants ON chat_messages
    FOR INSERT WITH CHECK (
        auth.uid() = sender_id AND
        EXISTS (
            SELECT 1 FROM sessions s
            WHERE s.id = session_id
            AND (s.user_id = auth.uid() OR s.specialist_id = auth.uid())
        )
    );

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to update specialist rating
CREATE OR REPLACE FUNCTION update_specialist_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE specialists
    SET 
        rating = (
            SELECT AVG(rating)::DECIMAL(3,2)
            FROM reviews
            WHERE specialist_id = NEW.specialist_id
        ),
        total_reviews = (
            SELECT COUNT(*)
            FROM reviews
            WHERE specialist_id = NEW.specialist_id
        )
    WHERE id = NEW.specialist_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for rating updates
CREATE TRIGGER trigger_update_specialist_rating
AFTER INSERT OR UPDATE ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_specialist_rating();

-- Function to update user tokens
CREATE OR REPLACE FUNCTION update_user_tokens()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE users
    SET tokens = tokens + NEW.amount
    WHERE id = NEW.user_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for token updates
CREATE TRIGGER trigger_update_user_tokens
AFTER INSERT ON token_transactions
FOR EACH ROW
EXECUTE FUNCTION update_user_tokens();

-- Function to check session eligibility (enough tokens)
CREATE OR REPLACE FUNCTION check_session_tokens()
RETURNS TRIGGER AS $$
DECLARE
    user_tokens INTEGER;
BEGIN
    SELECT tokens INTO user_tokens
    FROM users
    WHERE id = NEW.user_id;
    
    IF user_tokens < NEW.tokens_charged THEN
        RAISE EXCEPTION 'Insufficient tokens. User has % tokens, session requires %', user_tokens, NEW.tokens_charged;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for token check before session
CREATE TRIGGER trigger_check_session_tokens
BEFORE INSERT ON sessions
FOR EACH ROW
EXECUTE FUNCTION check_session_tokens();

-- ============================================
-- VIEWS
-- ============================================

-- View for specialist profiles (public info only)
CREATE VIEW specialist_profiles AS
SELECT 
    s.id,
    u.full_name,
    u.profile_photo_url,
    s.specialization,
    s.languages,
    s.experience_years,
    s.bio,
    s.education,
    s.certifications,
    s.rating,
    s.total_reviews,
    s.total_sessions,
    s.hourly_rate_tokens
FROM specialists s
JOIN users u ON s.id = u.id
WHERE s.verification_status = 'verified';

-- View for upcoming sessions
CREATE VIEW upcoming_sessions AS
SELECT 
    s.*,
    u.full_name AS user_name,
    sp.full_name AS specialist_name
FROM sessions s
JOIN users u ON s.user_id = u.id
LEFT JOIN users sp ON s.specialist_id = sp.id
WHERE s.status = 'scheduled'
AND s.scheduled_at > NOW()
ORDER BY s.scheduled_at;

-- ============================================
-- SAMPLE DATA (for testing)
-- ============================================

-- Insert sample user
INSERT INTO users (email, user_type, full_name, tokens) VALUES
('shouvik@example.com', 'user', 'Shouvik Banik', 100);

-- Insert sample specialist
INSERT INTO users (id, email, user_type, full_name, tokens) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'sarah.johnson@example.com', 'specialist', 'Dr. Sarah Johnson', 0);

INSERT INTO specialists (
    id, 
    specialization, 
    languages, 
    experience_years, 
    bio, 
    education,
    verification_status,
    hourly_rate_tokens
) VALUES (
    '550e8400-e29b-41d4-a716-446655440000',
    ARRAY['anxiety', 'depression', 'cbt'],
    ARRAY['English', 'Hindi'],
    8,
    'Compassionate psychologist specializing in anxiety and depression',
    'PhD in Clinical Psychology, Stanford University',
    'verified',
    50
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Composite indexes for common queries
CREATE INDEX idx_sessions_user_status ON sessions(user_id, status);
CREATE INDEX idx_sessions_specialist_upcoming ON sessions(specialist_id, scheduled_at) 
    WHERE status = 'scheduled' AND scheduled_at > NOW();

-- Full-text search on specialist bios
CREATE INDEX idx_specialists_bio_search ON specialists USING gin(to_tsvector('english', bio));

-- ============================================
-- BACKUP AND MAINTENANCE
-- ============================================

-- Enable automatic backups (set in Supabase dashboard)
-- Enable Point-in-Time Recovery (PITR)
-- Set up scheduled vacuuming for performance

-- ============================================
-- SECURITY NOTES
-- ============================================

-- 1. Always use Row Level Security (RLS)
-- 2. Never expose sensitive data in public views
-- 3. Use parameterized queries to prevent SQL injection
-- 4. Encrypt sensitive columns (license_number, etc.)
-- 5. Regular security audits
-- 6. Monitor for unusual access patterns

-- ============================================
-- MIGRATION SCRIPT
-- ============================================

-- To migrate from Firebase:
-- 1. Export Firestore data
-- 2. Transform JSON to SQL
-- 3. Run this schema
-- 4. Import transformed data
-- 5. Verify data integrity
-- 6. Update application to use PostgreSQL
