package controllers

import (
	"Vanaraj10/GOF-Notes/config"
	"Vanaraj10/GOF-Notes/services"
	"Vanaraj10/GOF-Notes/utils"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo/options"
	"golang.org/x/oauth2"
)

// Redirects to Google OAuth
func GoogleLogin(c *gin.Context) {
	url := services.GoogleOAuthConfig.AuthCodeURL("state", oauth2.AccessTypeOffline)
	c.Redirect(http.StatusFound, url)
}

// Handles callback, issues JWT, redirects to app
func GoogleCallback(c *gin.Context) {
	code := c.Query("code")
	token, err := services.GoogleOAuthConfig.Exchange(context.Background(), code)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "OAuth exchange failed"})
		return
	}

	accessToken := token.AccessToken
	client := &http.Client{}
	userInfoReq, _ := http.NewRequest("POST", "https://www.googleapis.com/oauth2/v3/userinfo", nil)
	userInfoReq.Header.Set("Authorization", "Bearer "+accessToken)
	resp, err := client.Do(userInfoReq)
	if err != nil || resp.StatusCode != 200 {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get user info"})
		return
	}
	defer resp.Body.Close()
	body, _ := io.ReadAll(resp.Body)
	var userinfo struct {
		Sub   string `json:"sub"`
		Email string `json:"email"`
		Name  string `json:"name"`
	}
	if err := json.Unmarshal(body, &userinfo); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse user info"})
		return
	}

	googleID := userinfo.Sub
	email := userinfo.Email
	name := userinfo.Name

	// Upsert user in DB
	usersCollection := config.DB.Collection("users")
	filter := bson.M{"google_id": googleID}
	update := bson.M{
		"$set": bson.M{
			"name":       name,
			"email":      email,
			"google_id":  googleID,
			"updated_at": time.Now(),
		},
		"$setOnInsert": bson.M{
			"created_at": time.Now(),
		},
	}
	print("Upserting user:", googleID, email, name)
	opts := options.Update().SetUpsert(true)
	_, err = usersCollection.UpdateOne(context.Background(), filter, update, opts)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update or insert user"})
		return
	}

	// Issue JWT
	jwtToken, err := utils.GenerateJWT(googleID, email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate JWT"})
		return
	}
	
	// Redirect to your app with token (custom scheme)
	redirectURL := fmt.Sprintf("myapp://auth?token=%s", jwtToken)
	c.Redirect(http.StatusFound, redirectURL)
}
