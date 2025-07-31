package models

import "time"

type Quiz struct {
	ID        string     `bson:"_id,omitempty"`
	OwnerID   string     `bson:"owner_id"`
	Topic     string     `bson:"topic"`
	Questions []Question `bson:"questions"`
	CreatedAt time.Time  `bson:"created_at"`
}
type Question struct {
	Text    string   `bson:"text"`
	Options []string `bson:"options"`
	Answer  int   `bson:"answer"`
}
