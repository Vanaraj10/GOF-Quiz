package services

import (
	"context"
	"fmt"
	"os"
	"strings"

	"github.com/google/generative-ai-go/genai"
	"google.golang.org/api/option"
)

func GenerateQuizWithGemini(topic string) (string, error) {
	apiKey := os.Getenv("GEMINI_API_KEY")
	if apiKey == "" {
		return "", fmt.Errorf("GEMINI_API_KEY environment variable is not set")
	}
	ctx := context.Background()
	client, err := genai.NewClient(ctx, option.WithAPIKey(apiKey))

	if err != nil {
		return "", fmt.Errorf("failed to create Gemini client: %w", err)
	}
	defer client.Close()

	model := client.GenerativeModel("gemini-2.0-flash")
	prompt := fmt.Sprintf(`Generate a quiz about "%s". The quiz should have 2 multiple choice questions.
Respond ONLY with a JSON array, where each item has:
- "text": the question,
- "options": an array of answer choices,
- "answer": the correct answer.

Example:
[
  {
    "text": "What is ...?",
    "options": ["A", "B", "C", "D"],
    "answer": "A"
  }
]
`, topic)

   resp,err := model.GenerateContent(ctx, genai.Text(prompt))
   if err != nil {
	return "", fmt.Errorf("failed to generate content: %w", err)
   }
   if len(resp.Candidates) > 0 {
	content := resp.Candidates[0].Content.Parts[0].(genai.Text)
	indexStart := strings.Index(string(content), "[")
	indexEnd := strings.LastIndex(string(content), "]")

	if indexStart == -1 || indexEnd == -1 || indexEnd < indexStart {
		return "", fmt.Errorf("invalid response format")
	}
	contentStr := string(content)[indexStart : indexEnd+1]
	
	println("Generated content:", contentStr)
	return contentStr, nil
   }
   return "", fmt.Errorf("no content generated")
}
