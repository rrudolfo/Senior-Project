const express = require("express");
const app = express();
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
// SAVE TO FIRESTORE

async function saveUserData(userId, updateData) {
  const docRef = db.collection("users").doc(userId);

  // Validate 'name' if present
  if (updateData.name !== undefined && typeof updateData.name !== "string") {
    throw new Error("Invalid name format: name must be a string");
  }

  try {
    await docRef.set(updateData, { merge: true }); // partial update
    return `Data saved for user ID: ${userId}`;
  } catch (error) {
    throw new Error(`Error saving data: ${error.message}`);
  }
}

//UPDATE THE USER'S NAME
async function mergeUpdatedUserName(userId, name){
  if(!userId) {
    throw new Error("Failure to updateUserName");
  } 
  try{
    const docRef = db.collection("users").doc(userId);
    await docRef.update({
      name: name
    });
    return `User's name has been updated: ${name}`
  }catch (error) {
    throw new Error(`Error merging data: ${error.message}`);
  }
}
//UPDATE THE USER'S EMAIL
async function mergeUpdatedUserEmail(userId, email){
  if(!userId) {
    throw new Error("Failure to updateUserEmail");
  } 
  try{
    const docRef = db.collection("users").doc(userId);
    await docRef.update({
      email: email
    });
    return `User's email has been updated: ${email}`;
  }catch (error) {
    throw new Error(`Error merging data: ${error.message}`);
  }
}
//UPDATE THE USER'S PASSWORD
async function mergeUpdatedUserPassword(userId, password){
  if(!userId) {
    throw new Error("Failure to updateUserPassword");
  } 
  try{
    const docRef = db.collection("users").doc(userId);
    await docRef.update({
      password: password
    })
    return `User's password has been updated!`
  }catch (error) {
    throw new Error(`Error merging data: ${error.message}`);
  }
}

async function saveUserTokens(userId, refreshToken, accessToken) {
  const docRef = db.collection("users").doc(userId);

  try {
    await docRef.set(
      { refreshToken: refreshToken, accessToken: accessToken },
      { merge: true }
    );

    return `Refresh token saved for user ID: ${userId}`;
  } catch (error) {
    throw new Error(`Error saving refresh token: ${error.message}`);
  }
}

// Create function for getting just the access token.
// GET DATA FROM FIRESTORE
async function getUserData(userId) {
  const docRef = db.collection("users").doc(userId);
  try {
    const doc = await docRef.get();
    if (doc.exists) {
      return doc.data();
    } else {
      throw new Error(`No data found for user ID: ${userId}`);
    }
  } catch (error) {
    throw new Error(`Error retrieving data: ${error.message}`);
  }
}
// GET USER TOKEN FROM FIRESTORE
async function getUserTokens(userId) {
  if (!userId) {
    throw new Error("Invalid userId provided to getUserTokens");
  }

  try {
    const docRef = db.collection("users").doc(userId);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new Error(`User document not found for userId: ${userId}`);
    }

    const data = doc.data();
    if (!data?.refreshToken || !data?.accessToken) {
      throw new Error(
        `Missing refreshToken or accessToken for userId: ${userId}`
      );
    }

    return {
      refreshToken: data.refreshToken,
      accessToken: data.accessToken,
    };
  } catch (error) {
    console.error(`Error fetching tokens for userId ${userId}:`, error);
    throw error;
  }
}

//Save playback state from spotify into firestore
async function savePlaybackState(playbackState) {
  try {
    if (playbackState.item && playbackState.item.type === "episode") {
      const episodeId = playbackState.item.id;
      const progressMs = playbackState.progress_ms;

      // Save the progress to Firestore
      await db.collection("episodeProgress").doc(episodeId).set({
        progressMs: progressMs,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Progress saved for episode ${episodeId}: ${progressMs} ms`);
    }
  } catch (error) {
    throw new error(`Error saving playback state into Firestore: ${error.message}`);
  }
}

app.post('/toggle-favorite-episode', async (req, res) => {
  const { userId, episodeId } = req.body;

  if (!userId || !episodeId) {
    return res.status(400).json({ error: 'userId and episodeId are required' });
  }

  try {
    const favoriteEpisodeDocRef = db.collection('users').doc(userId).collection('favoriteEpisodes').doc(episodeId);

    // Check if the episode is already in the favorites collection
    const docSnapshot = await favoriteEpisodeDocRef.get();

    if (docSnapshot.exists) {
      // If the episode is already a favorite, remove it (unfavorite)
      await favoriteEpisodeDocRef.delete();
      return res.status(200).json({ message: `Episode ${episodeId} removed from favorites.` });
    } else {
      // If the episode is not a favorite, add it (favorite)
      await favoriteEpisodeDocRef.set({
        episodeId: episodeId,
      });
      return res.status(200).json({ message: `Episode ${episodeId} added to favorites.` });
    }
  } catch (error) {
    console.error("Error toggling favorite episode:", error.message);
    return res.status(500).json({ error: `Error toggling favorite episode: ${error.message}` });
  }
});


//Save a podcast episode the user likes
async function saveFavoriteEpisode(playbackState, userId){
  if(!userId) {
    throw new Error("Invalid userId provided to saveFavoriteEpisode");
  } 
  try {
    if(playbackState.item && playbackState.item.type === "episode") {
      const episodeId = playbackState.item.id;
      const favoriteEpisodeDocRef = db.doc(db, "users", userId, "favoriteEpisodes", episodeId);
      //OR db.collection("users").doc(userId, "favoriteEpisodes", episodeId);
      await db.set(favoriteEpisodeDocRef, {
        episodeId: episodeId
      });
      console.log(`Favorite Episode saved! Episode: ${episodeId} to user ${userId}`);
    }
  } catch (error) {
    throw new Error(`Error saving favorite episode into Firestore: ${error.message}`);
  }
}

// app.post('/save-episode', async (req, res) => {
//     const { userId, episode } = req.body;

//     // Ensure userId and episode data are present
//     if (!userId || !episode || !episode.episodeId) {
//         return res.status(400).json({error: 'Missing userId or episode data'});
//     }

//     try {
//         // Reference to Firestore where episodes will be saved
//         const episodeRef = db
//             .collection('users')
//             .doc(userId)
//             .collection('savedEpisodes')
//             .doc(episode.episodeId);

//         // Save the episode data to Firestore
//         await episodeRef.set(episode);

//         return res.status(200).json({ message: 'Episode saved successfully' });
//     } catch (error) {
//         console.error('Error saving episode:', error);
//         return res.status(500).json({ error: 'Failed to save episode' });
//     }
// });


app.get('/get-episodes/:userId', async (req, res) => {
    const { userId } = req.params;

    try {
        const snapshot = await db
            .collection('users')
            .doc(userId)
            .collection('savedEpisodes')
            .get();

        const episodes = snapshot.docs.map(doc => doc.data());
        return res.status(200).json({ episodes });
    } catch (error) {
        console.error('Error retrieving episodes:', error);
        return res.status(500).json({ error: 'Failed to retrieve episodes' });
    }
});

//DELETE A USER'S INFO FROM FIRESTORE
async function deleteDataFromFirestore(userId) {
  const docRef = db.collection("users").doc(userId);
  try{
    const doc = await docRef.get();
    if(doc.exists){
      doc.delete();
      console.log(`Data on ${userId} deleted!`);
    } else {
      throw new Error(`Error finding user ${userId}`);
    }
  } catch (error) {
    throw new Error(`Error deleting data: ${error.message}`);
  }
}

//EXPORT FUNCTIONS TO BE UTILIZED IN OTHER NODEJS FILES
module.exports = {
  db,
  saveUserData,
  mergeUpdatedUserName,
  mergeUpdatedUserEmail,
  mergeUpdatedUserPassword,
  saveUserTokens,
  getUserData,
  getUserTokens,
  savePlaybackState,
  saveFavoriteEpisode
};