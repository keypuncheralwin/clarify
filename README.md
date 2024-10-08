# Clarify

Clarify is a mobile application designed to enhance the way users consume online content by providing clear, concise summaries and assessments of articles and YouTube videos. The app aims to eliminate the common frustrations of online browsing, such as misleading headlines, cluttered pages, and distracting elements, by offering users an efficient way to determine the quality and relevance of the content before engaging with it.

## Features

- **Content Analysis**: Clarify utilizes the Google Gemini API to analyze article content and YouTube videos. It provides users with a clarity score (0-10) to indicate how accurately a title or thumbnail represents the actual content.
- **Headline Evaluation**: The app displays a clarity score for each article or video, explaining the score based on the content's alignment with its title or thumbnail.
- **Summarization**: Clarify offers a brief, meaningful summary of the content, highlighting the key points in a straightforward manner.
- **History Management**: Users can access a history of their analyzed links, view content summaries within the app, and share the clarified results with others.

## Technologies Used

- **Flutter**: The front-end framework used for developing the cross-platform mobile app.
- **Firebase**: 
  - **Firebase Authentication**: Manages user authentication.
  - **Firestore**: Stores user data and history of analyzed links.
  - **Cloud Functions**: Hosts the backend logic written in Express.js with TypeScript.
- **Google Gemini API**: Analyzes the content of articles and YouTube videos, providing summaries and clarity scores.
- **Resend**: Handles email verification processes.
- **Express.js with TypeScript**: Implements the backend logic, hosted on Google Cloud Functions.

## Usage

Clarify allows users to share a link of an article or YouTube video to the app for analysis. The app then uses the Google Gemini API to generate a clarity score, provide a brief summary, and determine whether the title or thumbnail accurately reflects the content. Users can view these analyses within the app and access their history of analyzed links.

## Important Note for Gemini Competition Judges

You can easily run the Clarify app on your device by installing the provided APK file (Clarify.apk). If you only wish to run the front end without setting up the backend, head to the [Running the Frontend Locally](#running-the-frontend-locally) section below to run the flutter app using the live backend URL which has been provided along with the submission form. If you wish to run the whole project locally, please read on. Thank you!

# Running the Project
Please note that this is a mono repo containing both the front end and the backend. To set up and run the project locally, you will need to have Flutter, Node.js, and ngrok installed on your machine. You will also need to create a new firebase project and source a resend key. You can still run the project without a resend key with a placeholder string but note that the sign in/sign up section of the app will not work.

## Setting Up and Running the Backend Locally

1. **Clone the Repository:**
   - Clone this repository and navigate to the `backend/functions` folder.

2. **Create and Configure the Environment File:**
   - Create a `.env` file in the `backend/functions` directory.
   - Populate this file with your own copy of the following environment variables:
     - `RESEND_KEY`
     - `GEMINI_API_TOKEN`
   - Refer to the `.env.example` file for guidance.

3. **Google Cloud Service Account Setup:**
   - Assuming you've already created a firebase project to run this project, you will need to create a new service account in the Google Cloud Console for this project.
   - Generate a key for the service account, download the key.json, and place it inside the `backend/functions/src` folder.

4. **Install Dependencies and Run the Backend:**
   - Run `npm install` to install the necessary dependencies.
   - Run `npm run serve` to start a local instance of the cloud function.

5. **Retrieve the Backend URL:**
   - After running the backend, note the URL generated by Google Cloud Functions. It should resemble:
     ```
     functions[us-central1-api]: http function initialized (http://127.0.0.1:5001/project-name/api)
     ```
   - Take note of the port number (e.g., `5001`) used by the backend.

6. **Expose Backend to the Internet with ngrok:**
   - Open a new terminal and run the following command:
     ```
     ngrok http 5001
     ```
     (Make sure to use the port number where the backend is running.)
   - Note the ngrok URL generated, which should look something like:
     ```
     https://c23a-49-197-153-76.ngrok-free.app
     ```
   - This URL creates a secure tunnel between your local machine and the internet, making your local development server accessible publicly. This exposes your local development server to the public which means that anyone with the ngrok URL can access your locally hosted project. Once you’re done testing or sharing the URL, you can stop ngrok by pressing Ctrl+C in the terminal where it’s running. This will close the tunnel and make the local server no longer accessible from the internet. Always remember to keep track of the ngrok URL and the corresponding port it’s forwarding to ensure smooth and secure testing.

7. **Prepare the Frontend URL:**
   - To create the URL for the frontend, append the path from your local backend URL (e.g., `/project-name/api`) to the ngrok URL. It should look like:
     ```
     https://c23a-49-197-153-76.ngrok-free.app/project-name/api
     ```
   - This URL will be used by the frontend to access the backend.

## Running the Frontend Locally

1. **Navigate to the App Directory:**
   - `cd` into the `app` folder.

2. **Install Dependencies:**
   - Run `flutter pub get` to install the necessary Flutter dependencies.

3. **Configure the Environment:**
   - Create a new `.env` file in the `app` directory and populate the `BASE_URL` with the backend URL created earlier (e.g. `https://c23a-49-197-153-76.ngrok-free.app/project-name/api`).

4. **Set Up the Config File:**
   - Navigate to `app/android/app/src/main/assets`.
   - Copy the content from `exampleConfig.yml` and create a new file in the same directory called `config.yml`.
   - Paste the content into `config.yml` and and populate the `backend_url:` with the backend URL created earlier (e.g. `https://c23a-49-197-153-76.ngrok-free.app/project-name/api`).

5. **Run the App:**
   - Ensure you have either an Android simulator running or an Android phone connected to your PC with USB debugging enabled.
   - Run the app by executing the following command inside the `app` folder:
     ```
     flutter run
     ```
   - If multiple devices or simulators are detected, Flutter will prompt you to select a device. Choose your preferred device to run the app.

Clarify is user-friendly and includes a "How to Use" section in the account screen. For further details on how Clarify works, you can watch the Gemini competition submission video [here](#https://drive.google.com/file/d/1fEJ92tpuz5EBWXESHpOVvjvlkTw-qnl5/view?usp=sharing).

