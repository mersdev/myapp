package repository

import (
	"context"
	"time"
	"encoding/json"

	"cognitive-training-backend/models"
	"github.com/google/uuid"
	supa "github.com/supabase-community/supabase-go"
)

type GameRepository struct {
	client *supa.Client
}

func NewGameRepository(client *supa.Client) *GameRepository {
	return &GameRepository{client: client}
}

func (r *GameRepository) CreateSession(ctx context.Context, userID uuid.UUID) (*models.GameSession, error) {
	initialScore := models.ScoreDetails{
		Color: 0,
		Shape: 0,
		Size:  0,
		Total: 0,
	}

	session := &models.GameSession{
		ID:        uuid.New(),
		UserID:    userID,
		Score:     initialScore,
		CreatedAt: time.Now(),
	}

	_, err := r.client.DB.From("game_sessions").Insert(session).Execute()
	if err != nil {
		return nil, err
	}

	return session, nil
}

func (r *GameRepository) UpdateSession(ctx context.Context, sessionID uuid.UUID, update *models.UpdateGameSessionRequest) error {
	_, err := r.client.DB.From("game_sessions").
		Update(map[string]interface{}{
			"score":            update.Score,
			"rule_changes":     update.RuleChanges,
			"duration_seconds": update.DurationSecs,
			"completed_at":     update.CompletedAt,
		}).
		Eq("id", sessionID).
		Execute()

	return err
}

func (r *GameRepository) GetUserSessions(ctx context.Context, userID uuid.UUID) ([]models.GameSession, error) {
	var sessions []models.GameSession
	
	_, err := r.client.DB.From("game_sessions").
		Select("*").
		Eq("user_id", userID).
		Order("created_at", &supa.OrderOpts{Ascending: false}).
		Execute(&sessions)

	if err != nil {
		return nil, err
	}

	return sessions, nil
}

func (r *GameRepository) GetLeaderboard(ctx context.Context, limit int) ([]models.LeaderboardEntry, error) {
	var leaderboard []models.LeaderboardEntry

	query := `
		WITH UserScores AS (
			SELECT 
				gs.user_id,
				auth.users.email as user_email,
				gs.score,
				COUNT(*) as total_games,
				AVG((gs.score->>'total')::int) as average_score
			FROM game_sessions gs
			JOIN auth.users ON gs.user_id = auth.users.id
			WHERE gs.completed_at IS NOT NULL
			GROUP BY gs.user_id, auth.users.email
		)
		SELECT 
			user_id,
			user_email,
			(
				SELECT score
				FROM game_sessions gs2
				WHERE gs2.user_id = UserScores.user_id
				ORDER BY (gs2.score->>'total')::int DESC
				LIMIT 1
			) as high_score,
			total_games,
			average_score
		FROM UserScores
		ORDER BY average_score DESC
		LIMIT $1
	`

	_, err := r.client.DB.RawQuery(query, limit).Execute(&leaderboard)
	if err != nil {
		return nil, err
	}

	return leaderboard, nil
}

func (r *GameRepository) GetUserStats(ctx context.Context, userID uuid.UUID) (*models.LeaderboardEntry, error) {
	var stats []models.LeaderboardEntry

	query := `
		WITH UserScores AS (
			SELECT 
				gs.user_id,
				auth.users.email as user_email,
				gs.score,
				COUNT(*) as total_games,
				AVG((gs.score->>'total')::int) as average_score
			FROM game_sessions gs
			JOIN auth.users ON gs.user_id = auth.users.id
			WHERE gs.user_id = $1 AND gs.completed_at IS NOT NULL
			GROUP BY gs.user_id, auth.users.email
		)
		SELECT 
			user_id,
			user_email,
			(
				SELECT score
				FROM game_sessions gs2
				WHERE gs2.user_id = UserScores.user_id
				ORDER BY (gs2.score->>'total')::int DESC
				LIMIT 1
			) as high_score,
			total_games,
			average_score
		FROM UserScores
	`

	_, err := r.client.DB.RawQuery(query, userID).Execute(&stats)
	if err != nil {
		return nil, err
	}

	if len(stats) == 0 {
		return nil, nil
	}

	return &stats[0], nil
} 