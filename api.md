# GOF-Quiz Backend API Documentation

## Authentication

### 1. Google OAuth Login
**GET /auth/google/login**

- Redirects user to Google OAuth login.
- No request body.
- No authentication required.

---

### 2. Google OAuth Callback
**GET /auth/google/callback?code=...**

- Handles Google OAuth callback.
- No request body.
- No authentication required.
- Returns:
  - `user`: Google user info
  - `token`: JWT for authenticated requests

---

## Quiz Management

### 3. Generate Quiz
**POST /quiz/generate**

- Creates a new quiz using Gemini AI.
- **Headers:**  
  `Authorization: Bearer <JWT>`
- **Request Body:**
  ```json
  {
    "topic": "Design Patterns"
  }
  ```
- **Response:**
  ```json
  {
    "quiz": {
      "owner_id": "google_id",
      "topic": "Design Patterns",
      "questions": [
        {
          "text": "What is ...?",
          "options": ["A", "B", "C", "D"],
          "answer": "A"
        }
      ],
      "created_at": "2025-07-26T12:34:56Z"
    }
  }
  ```

---

### 4. List My Quizzes (Metadata Only)
**GET /quiz/my**

- Lists all quizzes created by the authenticated user.
- **Headers:**  
  `Authorization: Bearer <JWT>`
- **Response:**
  ```json
  {
    "quizzes": [
      {
        "id": "64b7c2e...",
        "topic": "Design Patterns",
        "created_at": "2025-07-26T12:34:56Z"
      }
    ]
  }
  ```

---

### 5. Get Quiz By ID
**GET /quiz/:id**

- Returns full quiz details for the given quiz ID.
- **Headers:**  
  `Authorization: Bearer <JWT>`
- **Response:**
  ```json
  {
    "quiz": {
      "id": "64b7c2e...",
      "owner_id": "google_id",
      "topic": "Design Patterns",
      "questions": [
        {
          "text": "What is ...?",
          "options": ["A", "B", "C", "D"],
          "answer": "A"
        }
      ],
      "created_at": "2025-07-26T12:34:56Z"
    }
  }
  ```

---

### 6. Delete Quiz
**DELETE /quiz/:id**

- Deletes the quiz with the given ID (only if owned by the authenticated user).
- **Headers:**  
  `Authorization: Bearer <JWT>`
- **Response:**
  ```json
  {
    "message": "Quiz deleted"
  }
  ```

---

## Error Responses

All endpoints may return errors in this format:
```json
{
  "error": "Error message"
}
```

---

## Authentication

- For all protected endpoints, include the JWT in the `Authorization` header:
  ```
  Authorization: Bearer <your-jwt-token>
  ```

---

## Notes

- All dates/times are in ISO 8601 format (UTC).
- Quiz attempts are not stored; answer checking is done on the frontend.
- All endpoints return JSON.

---