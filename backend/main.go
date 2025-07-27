package main

import (
	"Vanaraj10/GOF-Notes/config"
	"Vanaraj10/GOF-Notes/routes"
	"Vanaraj10/GOF-Notes/services"
	"log"
	"os"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	godotenv.Load();

	config.InitConfig()
    services.InitGoogleOAuth()

	r := gin.Default()
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
	}))
	routes.RegisterRoutes(r)
	r.GET("/",func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "Welcome to GOF-Quiz API",
		})
	})
	log.Println("Starting server on port 8080")
	port := os.Getenv("PORT")
	if port == "" {
	   log.Fatal("PORT is not set in .env file")
	}
	r.Run(":" + port) // listen and serve on
}