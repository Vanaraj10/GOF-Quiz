package controllers

import (
	"Vanaraj10/GOF-Notes/config"
	"Vanaraj10/GOF-Notes/models"
	"Vanaraj10/GOF-Notes/services"
	"encoding/json"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func GenerateQuiz(c *gin.Context) {
	var req struct {
		Topic string `json:"topic"`
	}
	if err := c.ShouldBindJSON(&req); err != nil || req.Topic == "" {
		c.JSON(400, gin.H{"error": "Invalid request"})
		return
	}
	googleID, exists := c.Get("google_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Unauthorized",
		})
		return
	}

	raw, err := services.GenerateQuizWithGemini(req.Topic)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to generate quiz: " + err.Error(),
		})
		return
	}
	questions := []models.Question{}
	if err := json.Unmarshal([]byte(raw), &questions); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to parse quiz content: " + err.Error(),
		})
		return
	}
	quiz := models.Quiz{
		OwnerID:   googleID.(string),
		Topic:     req.Topic,
		Questions: questions,
		CreatedAt: time.Now(),
	}

	_, err = config.DB.Collection("quizzes").InsertOne(c, quiz)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to create quiz",
		})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"quiz": quiz,
	})
}

func ListMyQuizzes(c *gin.Context) {
	googleID, exists := c.Get("google_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Unauthorized",
		})
		return
	}
	cursor, err := config.DB.Collection("quizzes").Find(c, bson.M{"owner_id": googleID.(string)})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to fetch quizzes",
		})
		return
	}
	var quizzes []struct {
		ID        string    `bson:"_id"`
		Topic     string    `bson:"topic"`
		CreatedAt time.Time `bson:"created_at"`
	}
	if err := cursor.All(c, &quizzes); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to parse quizzes",
		})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"quizzes": quizzes,
	})
}

func GetQuizByID(c *gin.Context) {
	quizID := c.Param("id")
	ObjID, err := primitive.ObjectIDFromHex(quizID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid quiz ID"})
		return
	}
	var quiz models.Quiz
	err = config.DB.Collection("quizzes").FindOne(c, bson.M{"_id": ObjID}).Decode(&quiz)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch quiz"})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"quiz": quiz,
	})
}

func DeleteQuiz(c *gin.Context) {
	quizID := c.Param("id")
	googleID, exists := c.Get("google_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Unauthorized",
		})
		return
	}
	objID, err := primitive.ObjectIDFromHex(quizID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid quiz ID"})
		return
	}
	resp, err := config.DB.Collection("quizzes").DeleteOne(c, bson.M{"_id": objID, "owner_id":googleID.(string)})
	if err != nil || resp.DeletedCount == 0 {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete quiz"})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"message": "Quiz deleted successfully",
	})
}