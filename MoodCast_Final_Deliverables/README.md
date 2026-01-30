# MoodCast

MoodCast is an app that generates podcasts based on a user's mood and ETE. The user can search for the destination they are going to drive to, select the ETE that pops up, select their current mood, and then receive a curated stack of podcast episode to listen to. They can swipe through this stack to either favorite and dismiss episodes. Favorited episodes are shown in their own view and can be searched through. The user also has basic account settings to update their name or email.

_Last updated: 7 June 2025_

## What's needed to set up MoodCast?

To set up this project users will need:
- Server to host the Node.js code on
- Firebase database to use the Firestore functions that save and retrieve data
    - API key
- Spotify developer account to use the Spotify API and its certain endpoints
    - API key
    - Client ID
- ChatGPT developer account
    - API key

## How to set up MoodCast?

The Server
- Once you find a site to host your Node.js you can copy and paste all the files located in the glitch_server folder. Next, create a .env file to store your API keys. Add the Firebase and Spotify keys. Use the exact same variable names for these keys as used in server.js file. Next, add the Spotify redirect link in the .env. It will look something like this: myapp://spotify/callback. You will also need this set the redirect in the Spotify Developer console and your Xcode app. In addition to these keys and link, you will need to add the service account key, given to you by Firebase. This is Firebase's API key and instead of a variable, is a separate file. You will get this, after creating a project in Firebase.

The Database
- If using Firebase Firestore as the database, follow these steps. First create a new Firebase account. Firebase as easy directions you can follow on their website if needed. When creating a project, you will need to input data for your app like the bundle name. This will generate a info.plist. Drag this into your Xcode project. Next, enable Firebase auth and Firebase Firestore. After this, your database and authentication should work.

The App
- After opening the app, you must install the necessary packages. Go to the package manager and search for the Firebase package. (url is given when setting up Firebase) Search then select the package that pops up. Select the current version and then select Firebase Firestore and Firebase Authentication. Finally, make sure this callback is in your app project under URL Types: myapp://spotify/callback. Now your app should be ready to go!

After all these steps are completed successfully, you will have a working version of MoodCast!
