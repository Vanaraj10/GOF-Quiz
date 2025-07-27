package routes

import (
	"Vanaraj10/GOF-Notes/controllers"
	"Vanaraj10/GOF-Notes/middleware"

	"github.com/gin-gonic/gin"
)

func RegisterRoutes(r *gin.Engine) {
	// Web-based Google OAuth routes for browser-based login
	r.GET("/auth/google/login", controllers.GoogleLogin)
	r.GET("/auth/google/callback", controllers.GoogleCallback)

	// Removed mobile Google login route

	r.GET("/user/me", middleware.AuthRequired(), func(ctx *gin.Context) {
		ctx.JSON(200, gin.H{
			"message": "You are authenticated",
		})
	})
	r.POST("/quiz/generate", middleware.AuthRequired(), controllers.GenerateQuiz)
	r.GET("/quiz/my", middleware.AuthRequired(), controllers.ListMyQuizzes)
	r.GET("/quiz/:id", middleware.AuthRequired(), controllers.GetQuizByID)
	r.DELETE("/quiz/:id", middleware.AuthRequired(), controllers.DeleteQuiz)
}
