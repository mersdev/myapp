-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create game_sessions table with JSONB score column
CREATE TABLE game_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id),
    score JSONB NOT NULL DEFAULT '{"color": 0, "shape": 0, "size": 0, "total": 0}'::jsonb,
    rule_changes INTEGER DEFAULT 0,
    duration_seconds INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES auth.users(id)
);

-- Create indexes
CREATE INDEX idx_game_sessions_user_id ON game_sessions(user_id);
CREATE INDEX idx_game_sessions_score ON game_sessions((score->>'total'));
CREATE INDEX idx_game_sessions_created_at ON game_sessions(created_at);

-- Create function to validate score JSON structure
CREATE OR REPLACE FUNCTION validate_score_structure()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT (
        NEW.score ? 'color' AND 
        NEW.score ? 'shape' AND 
        NEW.score ? 'size' AND 
        NEW.score ? 'total' AND
        jsonb_typeof(NEW.score->'color') = 'number' AND
        jsonb_typeof(NEW.score->'shape') = 'number' AND
        jsonb_typeof(NEW.score->'size') = 'number' AND
        jsonb_typeof(NEW.score->'total') = 'number'
    ) THEN
        RAISE EXCEPTION 'Invalid score structure';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to validate score structure
CREATE TRIGGER validate_score_structure
BEFORE INSERT OR UPDATE ON game_sessions
FOR EACH ROW
EXECUTE FUNCTION validate_score_structure(); 