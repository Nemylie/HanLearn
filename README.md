# HanLearn - Smart Mandarin Learning App

<img src="assets/images/HanLearnLogo.png" alt="HanLearn Logo" width="200" />

## a) Group Members & Work Distribution
| Name | Matric Number | Responsibilities
| :--- | :--- | :---|
| Nurul Nadhirah Binti Zakaria | 2213698 | Translation Page, Quiz Page, Progress Tracking Page, Report |
| Azwa Nurnisya Binti Ayub | 2217418 | Vocabulary Bank Page, Database, Report |
| Nur Ain Binti Mohamad Hisham | 2216894 | Authentication, Settings Page, Dark Mode, Report |

## b) Project Title
**HanLearn - Smart Mandarin Learning App**

## c) Introduction
*   **Problem & Motivation:** Learning Mandarin Chinese is notoriously challenging for beginners due to its logographic writing system (Hanzi) and tonal pronunciation. Many existing learning resources are either too academic or lack engagement. There is a need for a streamlined, mobile-first solution that makes acquiring basic vocabulary and testing knowledge accessible and less intimidating.  

*   **Relevance:** As Mandarin becomes increasingly important in global business and culture, a tool that helps users bridge the language gap through daily practice, translation, and gamified quizzes is highly relevant for students, travelers, and lifelong learners. HanLearn is developed as a cross-platform mobile application using Flutter, supporting both Android and iOS devices which is feasible for all type of users.

## d) Objectives
1. To enable beginners to learn essential Mandarin vocabulary through structured and categorized lessons.
2. To assist users in understanding Mandarin in real-life situations using accurate English–Chinese translation tools.
3.  To implement an interactive quiz system that reinforces learning through active recall and immediate feedback.
4.  To create a personalized learning experience by tracking user progress, scores, and proficiency levels.

## e) Target Users
*   **Beginner Learners:** Individuals aged 7–35 with no prior Mandarin background who prefer mobile-based, self-paced learning with simple explanations.
*   **Students:** School or university students learning Mandarin who need a supplementary tool for revision, quizzes, and vocabulary reinforcement.
*   **Travelers:** Tourists and casual learners who needs quick references and translation assistance for daily interactions (food, travel, directions).

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

<img src="assets/images/Homescreen.jpg" alt="Homescreen" width="200" />

*   **Login Screen:** Minimalist design with a branded logo, input fields with icon prefixes, and a "Remember Me" checkbox.

<img src="assets/images/Dashboard.jpg" alt="Dashboard" width="200" />

*   **Home Dashboard:** A central hub featuring a "Welcome" header, a "Fun Fact" card, and a grid layout for quick navigation to Learn, Quiz, Translate, and Profile sections.

<img src="assets/images/Wordbank.jpg" alt="Wordbank" width="200" />

*   **Vocabulary List:** Clean card-based layout for each word, emphasizing readability of characters.

<img src="assets/images/Quiz.jpg" alt="Quiz" width="200" />

*   **Quiz Interface:** Focused view with the question at the top, large interactive answer buttons, and a progress bar.

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

## h) Flowchart / User Flow
1.  **Launch:** App opens. Checks `shared_preferences` for "Remember Me" or existing session.

2.  **Authentication:**
    *   If not logged in: User lands on **Login Screen** -> Enter credentials -> Validated by Firebase.
    *   If new user: **Register Screen** -> Create Account -> Profile created in Firestore.
3.  **Main Interaction (Home):** User arrives at **Dashboard**.
    *   *Path A (Learn):* Select Category -> View List -> Tap word for details.
    *   *Path B (Quiz):* Start Quiz -> Answer Q1...Q10 -> View Score -> Update Firestore Progress.
    *   *Path C (Translate):* Enter text -> View translation.
4.  **Termination:** User logs out -> Session cleared -> Return to Login.

<img width="393" height="388" alt="FYP Diagrams-HanLearn registration activity diagram drawio" src="https://github.com/user-attachments/assets/088f7ef6-c58e-43b5-ba04-678018d3ba91" />

> This flowchart shows the user signup and login process

<img width="583" height="535" alt="FYP Diagrams-HanLearn activity diagram drawio (1)" src="https://github.com/user-attachments/assets/df69b5ae-052b-4ff1-b7f2-1da7d4b816c1" />

> This flowchart shows user actions for each feature after login

## i) Final UI Screenshots

### 1. Authentication
**Login Screen:** Secure entry point with email/password and Google Sign-In options.
| Light Mode | Dark Mode |
| :---: | :---: |
| <img src="assets/screenshots/LoginLight.png" width="200" /> | <img src="assets/screenshots/LoginDark.png" width="200" /> |

**Register Screen:** Simple account creation form with validation.
| Light Mode | Dark Mode |
| :---: | :---: |
| <img src="assets/screenshots/RegisterLight.png" width="200" /> | <img src="assets/screenshots/RegisterDark.png" width="200" /> |

### 2. Main Dashboard
**Home Screen:** Central hub showing user progress, fun facts, and navigation to key modules.
| Light Mode | Dark Mode |
| :---: | :---: |
| <img src="assets/screenshots/HomeLight.png" width="200" /> | <img src="assets/screenshots/HomeDark.png" width="200" /> |

### 3. Learning Modules
**Vocabulary Bank:** Categorized word lists with expandable details (Hanzi, Pinyin, Meaning).
| Light Mode | Dark Mode |
| :---: | :---: |
| <img src="assets/screenshots/VocabLight.png" width="200" /> | <img src="assets/screenshots/VocabDark.png" width="200" /> |

**Translation:** Bidirectional translation tool with example sentences.
| Light Mode | Dark Mode |
| :---: | :---: |
| <img src="assets/screenshots/TranslateLight.png" width="200" /> | <img src="assets/screenshots/TranslateDark.png" width="200" /> |

### 4. Assessment & Tracking
**Quiz Interface:** Interactive questions to test vocabulary retention.
| Light Mode | Dark Mode |
| :---: | :---: |
| <img src="assets/screenshots/QuizLight.png" width="200" /> | <img src="assets/screenshots/QuizDark.png" width="200" /> |

**Progress Tracker:** Visual stats showing level, XP, and learning milestones.
| Light Mode | Dark Mode |
| :---: | :---: |
| <img src="assets/screenshots/ProgressLight.png" width="200" /> | <img src="assets/screenshots/ProgressDark.png" width="200" /> |

### 5. Settings
**Settings Page:** Customization options for theme (Dark/Light), account management, and app info.
| Light Mode | Dark Mode |
| :---: | :---: |
| <img src="assets/screenshots/SettingLight.png" width="200" /> | <img src="assets/screenshots/SettingDark.png" width="200" /> |

## j) Summary of Achieved Features

## k) Technical Explanation

### Technology Stack
**1. Framework:** Flutter (Dart) for cross-platform mobile app development.
**2. Firebase Integration:**
     - Firebase Authentication: Supports both email/password and google oauth..
     - Cloud Firestore: NoSQL database for storing user profiles and learning data.
     - Firestore Rules: Configured to ensure access only for authenticated users.
**3. State Management:** Provider package is used to manage and propagate state changes (user auth, quiz score, vocabulary data) across the widget tree efficiently.
**4. External Packages:**
     - `translator`: For API-based translatioin services.
     - `Ipinyin`: For converting Hanzi characters to Pinyin.
     - `shared_preferences`: For local storage of user settings (Remember me).
**5. Authentication:** Firebase auth with platform-specific providers (email/password, google oauth).

**6. Architecture/Design**

**7. Key Technical Decisions**

## l) Limitations & Future Enhancements

### Limitations
**1) Forgot Password**
   - Firebase email reset link requires access to the email inbox.
   - Email/password accounts: works for real emails that can receive the reset link.
   - Google sign-in accounts: password management is handled by Google, so reset is not supported within the app.
   - Dummary emails: reset link can be sent, but the link can't be accessed for the fake email
  
**2) Update Email:**
   - Changes user email in firebase auth and firestore profile.
   - Firebase requires reauthentication for email changes.
   - Email/password accounts: supported for real and dummy emails (no email verification needed).
   - Google sign-in accounts: not supported, as Google manages email, so changing it can cause inconsitent login behaviour

**3) Firestore Storage:**
   - The firestore spark plan (free) restricts the ability to upload media files.
  
### Future Enhancements
**1) Forgot Password:**
   - Allow resetting password for Google sign-in accounts using firebase authentication, if Google provides such feature.
   - Use alternative method for dummy emails users to confirm their identity (for example: using phone number or other form of user verification to ensure the user is legit before allowing them to change their email or password.

**2) Update Email:**
   - Support email update for Google sign-in accounts without causing login issues, possibly by managing firebase account linking directly.
   - Implement email verification for dummy email users when updating their email addresses.

**3) Firestore Storage:**
   - Consider upgrading to a paid firestore plan to unlock more storage capacity for uploading media files.


## m) References
*   **Flutter Documentation:** [https://flutter.dev/docs](https://flutter.dev/docs)
*   **Firebase Documentation:** [https://firebase.google.com/docs](https://firebase.google.com/docs)
*   **Provider Package:** [https://pub.dev/packages/provider](https://pub.dev/packages/provider)
*   **Material Design Guidelines:** [https://m3.material.io/](https://m3.material.io/)
