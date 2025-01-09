package models

import (
	"time"
	"encoding/json"

	"github.com/google/uuid"
)

// ScoreDetails stores the number of correct answers for each rule type
type ScoreDetails struct {
	Color  int `json:"color"`
	Shape  int `json:"shape"`
	Size   int `json:"size"`
	Total  int `json:"total"`
}

type GameSession struct {
	ID            uuid.UUID    `json:"id" db:"id"`
	UserID        uuid.UUID    `json:"user_id" db:"user_id"`
	Score         ScoreDetails `json:"score" db:"score"`
	RuleChanges   int         `json:"rule_changes" db:"rule_changes"`
	DurationSecs  int         `json:"duration_seconds" db:"duration_seconds"`
	CreatedAt     time.Time    `json:"created_at" db:"created_at"`
	CompletedAt   time.Time    `json:"completed_at,omitempty" db:"completed_at"`
}

type CreateGameSessionRequest struct {
	UserID uuid.UUID `json:"user_id" binding:"required"`
}

type UpdateGameSessionRequest struct {
	Score        ScoreDetails `json:"score" binding:"required"`
	RuleChanges  int         `json:"rule_changes" binding:"required"`
	DurationSecs int         `json:"duration_seconds" binding:"required"`
	CompletedAt  time.Time    `json:"completed_at" binding:"required"`
}

type GameSessionResponse struct {
	ID            uuid.UUID    `json:"id"`
	UserID        uuid.UUID    `json:"user_id"`
	Score         ScoreDetails `json:"score"`
	RuleChanges   int         `json:"rule_changes"`
	DurationSecs  int         `json:"duration_seconds"`
	CreatedAt     time.Time    `json:"created_at"`
	CompletedAt   time.Time    `json:"completed_at,omitempty"`
}

type LeaderboardEntry struct {
	UserID       uuid.UUID    `json:"user_id"`
	UserEmail    string       `json:"user_email"`
	HighScore    ScoreDetails `json:"high_score"`
	TotalGames   int         `json:"total_games"`
	AverageScore float64     `json:"average_score"`
} 