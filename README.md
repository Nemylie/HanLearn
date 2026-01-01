# HanLearn - Smart Mandarin Learning App

<img src="assets/images/HanLearnLogo.png" alt="HanLearn Logo" width="200" />

## a) Group Members
*   Nurul Nadhirah Binti Zakaria - 2213698
*   Azwa Nurnisya Binti Ayub - 22174118
*   Nur Ain Binti Mohamadd Hisham - 2216894

## b) Project Title
**HanLearn**

## c) Introduction
*   **Problem & Motivation:** Learning Mandarin Chinese is notoriously challenging for beginners due to its logographic writing system (Hanzi) and tonal pronunciation. Many existing learning resources are either too academic or lack engagement. There is a need for a streamlined, mobile-first solution that makes acquiring basic vocabulary and testing knowledge accessible and less intimidating.
*   **Relevance:** As Mandarin becomes increasingly important in global business and culture, a tool that helps users bridge the language gap through daily practice, translation, and gamified quizzes is highly relevant for students, travelers, and lifelong learners.

## d) Objectives
1.  To develop a mobile application that simplifies Mandarin vocabulary acquisition through categorized learning.
2.  To provide accurate English-Chinese translation tools to assist users in real-time understanding.
3.  To implement an interactive quiz system that reinforces learning through active recall and immediate feedback.
4.  To create a personalized learning experience by tracking user progress, scores, and proficiency levels.

## e) Target Users
*   **Beginner Learners:** Individuals starting their journey with Mandarin who need structured vocabulary lists.
*   **Students:** Language students requiring a supplementary tool for revision and practice.
*   **Travelers:** Tourists needing quick references and translation assistance for daily interactions (food, travel, directions).

## f) Features and Functionalities
1.  **User Authentication Module:**
    *   Secure Sign Up and Login using Firebase Authentication (Email/Password).
    *   "Remember Me" functionality for convenient access.
    *   Profile management (Display Name, Level).

2.  **Vocabulary Bank:**
    *   Categorized word lists (e.g., Daily Conversation, Education, Travel, Food).
    *   Rich display including Chinese Character (Hanzi), Pinyin, and English Meaning.
    *   Audio pronunciation support (planned).

3.  **Translation Module:**
    *   Bidirectional translation (English ↔ Mandarin).
    *   Displays result in Hanzi and Pinyin.
    *   Ability to save translations to "My Vocabulary".

4.  **Quiz & Practice Module:**
    *   Gamified testing with various question types (Multiple Choice, Meaning Match).
    *   Real-time scoring and feedback (Correct/Incorrect indicators).
    *   Result summaries to track performance per session.

5.  **Learning Progress Tracker:**
    *   Visual dashboard showing Total Score, Words Learned count, and current User Level.
    *   Persistent progress tracking using Cloud Firestore.

## g) Proposed UI Mock-up
The application features a modern, clean interface adhering to **Material Design 3** principles, utilizing a **Maroon (Primary) and White (Surface)** color scheme for a professional yet inviting aesthetic.

*   **Login Screen:** Minimalist design with a branded logo, input fields with icon prefixes, and a "Remember Me" checkbox.
*   **Home Dashboard:** A central hub featuring a "Welcome" header, a "Fun Fact" card, and a grid layout for quick navigation to Learn, Quiz, Translate, and Profile sections.
*   **Vocabulary List:** Clean card-based layout for each word, emphasizing readability of characters.
*   **Quiz Interface:** Focused view with the question at the top, large interactive answer buttons, and a progress bar.

## h) Architecture / Technical Design
*   **Framework:** Flutter (Dart) for cross-platform mobile application development.
*   **State Management:** **Provider** package is used to manage and propagate state changes (User Auth, Quiz Score, Vocabulary Data) across the widget tree efficiently.
*   **Backend:**
    *   **Firebase Authentication:** Handles identity management.
    *   **Cloud Firestore:** NoSQL database for storing user profiles and learning data.
*   **External Packages:**
    *   `translator`: For API-based translation services.
    *   `lpinyin`: For converting Hanzi characters to Pinyin.
    *   `shared_preferences`: For local storage of user settings (Remember Me).

## i) Data Model
The app uses a NoSQL document-based model in **Cloud Firestore**.

**Collection: `users`**
```json
{
  "uid": "string (PK)",
  "email": "string",
  "displayName": "string",
  "level": "number",
  "totalScore": "number",
  "wordsLearned": "number",
  "createdAt": "timestamp"
}
```

**Collection: `vocabulary`** (Global Content)
```json
{
  "id": "string (PK)",
  "character": "string",
  "pinyin": "string",
  "meaning": "string",
  "category": "string"
}
```

## j) Flowchart / User Flow
1.  **Launch:** App opens. Checks `shared_preferences` for "Remember Me" or existing session.
2.  **Authentication:**
    *   If not logged in: User lands on **Login Screen** -> Enter credentials -> Validated by Firebase.
    *   If new user: **Register Screen** -> Create Account -> Profile created in Firestore.
3.  **Main Interaction (Home):** User arrives at **Dashboard**.
    *   *Path A (Learn):* Select Category -> View List -> Tap word for details.
    *   *Path B (Quiz):* Start Quiz -> Answer Q1...Q10 -> View Score -> Update Firestore Progress.
    *   *Path C (Translate):* Enter text -> View translation.
4.  **Termination:** User logs out -> Session cleared -> Return to Login.

## k) References
*   **Flutter Documentation:** [https://flutter.dev/docs](https://flutter.dev/docs)
*   **Firebase Documentation:** [https://firebase.google.com/docs](https://firebase.google.com/docs)
*   **Provider Package:** [https://pub.dev/packages/provider](https://pub.dev/packages/provider)
*   **Material Design Guidelines:** [https://m3.material.io/](https://m3.material.io/)
