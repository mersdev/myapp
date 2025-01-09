package main

import (
	"log"
	"os"

	"cognitive-training-backend/handlers"
	"cognitive-training-backend/repository"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	supa "github.com/supabase-community/supabase-go"
)

func main() {
	if err := godotenv.Load(); err != nil {
		log.Printf("Warning: .env file not found")
	}

	supabaseURL := os.Getenv("SUPABASE_URL")
	supabaseKey := os.Getenv("SUPABASE_KEY")
	if supabaseURL == "" || supabaseKey == "" {
		log.Fatal("SUPABASE_URL and SUPABASE_KEY must be set")
	}

	// Initialize Supabase client
	supabase := supa.CreateClient(supabaseURL, supabaseKey)

	// Initialize repository and handler
	gameRepo := repository.NewGameRepository(supabase)
	gameHandler := handlers.NewGameHandler(gameRepo)

	// Setup Gin router
	r := gin.Default()

	// CORS middleware
	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Origin, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	})

	// Game session routes
	api := r.Group("/api")
	{
		api.POST("/sessions", gameHandler.StartSession)
		api.PUT("/sessions/:id", gameHandler.UpdateSession)
		api.GET("/users/:userId/sessions", gameHandler.GetUserSessions)
		api.GET("/users/:userId/stats", gameHandler.GetUserStats)
		api.GET("/leaderboard", gameHandler.GetLeaderboard)
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	if err := r.Run(":" + port); err != nil {
		log.Fatal(err)
	}
} 