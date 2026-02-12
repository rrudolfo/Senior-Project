const express = require("express"); //declare express API for Node.js
//COMMENTED OUT: DECLARED IN firestore-calls.js
//const admin = require("firebase-admin"); //to use any and all functions from the firebaseAPI(s)
const axios = require("axios");
//COMMENTED OUT: DECLARED IN spotify-calls.js
//const spotifyWebApi = require("spotify-web-api-node"); //declare function calls from the spotify API
const app = express();

app.use(express.json());
//COMMENTED OUT: DECLARED IN firestore-calls.js
// const serviceAccount = require("./serviceAccountKey.json");
// firestore.admin.initializeApp({
//   credential: firestore.admin.credential.cert(serviceAccount),
// });

// const spotifyApi = new spotifyWebApi({
//   clientId: process.env.SPOTIFY_CLIENT_ID,
//   clientSecret: process.env.SPOTIFY_CLIENT_SECRET,
//   redirectUri: process.env.SPOTIFY_REDIRECT_URI,
// });

const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
//COMMENTED OUT: DECLARED IN spotify-calls.js
const scopes = [
  "user-read-private",
  "user-read-email",
  "user-top-read",
  "user-read-playback-position",
  "user-read-playback-state",
  "user-read-currently-playing", 
  "user-modify-playback-state",
  "streaming",
  "user-library-modify",
  "playlist-modify-public",
  "playlist-modify-private",
];

//COMMENTED OUT: DECLARED IN spotify-calls.js
const firestore = require("./firestore-calls"); //EXPORT FOR FIRESTORE FUNCTIONS FROM firestore-calls.js
const spotify = require("./spotify-calls"); //EXPORT FOR SPOTIFY FUNCTIONS FROM spotify-calls.js
//COMMENTED OUT: DECLARED IN firestore-calls.js
//const db = admin.firestore(); //to specify and use the needed functions within the firestore API(s)

// ENDPOINTS

/* ------------------------------- SPOTIFY ENDPOINTS ------------------------------- */

// SPOTIFY LOGIN ENDPOINT
app.get("/login", (req, res) => {
  const authorizeURL = spotify.spotifyApi.createAuthorizeURL(scopes, "state");
  res.redirect(authorizeURL);
});

/// SPOTIFY LOGIN ENDPOINT
app.get("/spotify/callback", async (req, res) => {
  //"error": "Error exchanging code for access token"
  const code = req.query.code; // The code is sent by Spotify as a query parameter
  try {
    // Use the code to get the access token
    const data = await spotify.spotifyApi.authorizationCodeGrant(code);
    const { access_token, refresh_token } = data.body;

    // Optionally store these tokens in a database or send them back to the frontend
    res.status(200).send(access_token);
  } catch (error) {
    console.error("Error exchanging code for access token:", error);
    res.status(400).json({ error: "Error exchanging code for access token" });
  }
});

app.get("/podcasts/:mood/:userid", async (req, res) => {
  const { mood, userid } = req.params;
  const eteMinutes = parseEteMinutes(req.query.eteMinutes);

  try {
    const { refreshToken } = await firestore.getUserTokens(userid);
    spotify.spotifyApi.setRefreshToken(refreshToken);

    await ensureSpotifyClientToken();

    const discoverySignals = await firestore.getUserDiscoverySignals(userid);

    const episodes = await getPodcastEpisodes({
      mood,
      eteMinutes,
      discoverySignals,
    });

    res.status(200).json(episodes);
  } catch (error) {
    console.error("Error generating podcast episodes:", error);
    res.status(500).json({ error: error.message || "Failed to load podcasts" });
  }
});

app.get("/user-profile", async (req, res) => {
  try {
    const userId = req.query.userId;

    if (!userId) {
      return res
        .status(400)
        .json({ error: "Missing userId in query parameters" });
    }

    const { accessToken, refreshToken } = await firestore.getUserTokens(userId);

    spotify.spotifyApi.setRefreshToken(refreshToken);

    const refreshData = await spotify.spotifyApi.refreshAccessToken();
    const newAccessToken = refreshData.body.access_token;

    await firestore.saveUserTokens(userId, refreshToken, newAccessToken);

    spotify.spotifyApi.setAccessToken(newAccessToken);

    const data = await spotify.spotifyApi.getMe();

    res.json(data.body);
  } catch (error) {
    console.error("Error fetching user profile:", error);
    res.status(500).json({ error: "Failed to fetch user profile" });
  }
});

// const spotifyWebApi = require("spotify-web-api-node");
// const spotifyApi = new spotifyWebApi({
//   clientId: process.env.SPOTIFY_CLIENT_ID,
//   clientSecret: process.env.SPOTIFY_CLIENT_SECRET,
//   redirectUri: process.env.SPOTIFY_REDIRECT_URI,
// });

// SPOTIFY CALLBACK ENDPOINT
app.get("/callback", async (req, res) => {
  const { code, userId } = req.query;

  try {
    const data = await spotify.spotifyApi.authorizationCodeGrant(code);
    const access_token = data.body["access_token"];
    const refresh_token = data.body["refresh_token"];

    spotify.spotifyApi.setAccessToken(access_token);
    spotify.spotifyApi.setRefreshToken(refresh_token);

    const result = await firestore.saveUserTokens(
      userId,
      refresh_token,
      access_token
    );
    res.status(200).send(result);
  } catch (error) {
    console.error("Error in callback:", error);
    res.status(500).send("Authentication failed");
  }
});

// SPOTIFY USER PROFILE ENDPOINT
// app.get("/user-profile", async (req, res) => {
//   try {
//     const accessToken = req.query.access_token;
//     spotifyApi.setAccessToken(accessToken);
//     const userData = await spotifyApi.getMe();
//     res.json(userData.body);
//   } catch (error) {
//     console.error("Error fetching user profile:", error);
//     res.status(500).send("Error fetching user data");
//   }
// });

// ENDPOINT FOR LOGIN FOR SPOTIFY
app.get("/login", async (req, res) => {
  //200!
  const { client_id, URI, response_type } = req.params;
  const querystring = ""; //To be changed...
  console.log("requesting user authorization for spotify");
  try {
    const result = await res.redirect(
      "https://accounts.spotify.com/authorize?" +
        querystring.stringify({
          reponse_type: response_type,
          client_id: client_id,
          redirect_uri: URI,
        })
    ); //input to be changed...
    res.staus(200).send(result);
  } catch (error) {
    res.status(500).send(error.message);
  }
});
// ENDPOINT FOR SEARCHING FOR SEVERAL EPISODES
app.get("/episodes", async (req, res) => {
  try {
    const { ids, market } = req.query;
    const episodeId = ids.split(",");
    if (episodeId.length > 50) {
      return res.status(400).send("/search episodeId value exceeds 50");
    }
    const options = {};
    if (market) {
      options.market = market;
    }
    const data = await spotify.spotifyApi.getEpisodes(episodeId, market);
    //res.json(data.body);
    res.status(200).send(data);
  } catch (error) {
    res.status(500).send(`Error at /search endpoint: ${error.message}`);
  }
});
//ENDPOINT FOR GETTING GENRE(S)
app.get("/recommendations/available-genre-seeds", async (req, res) => {
  //Error at /recommendations/available-genre-seeds endpoint: spotifyApi.getGeneres is not a function
  try {
    let genreStrings = [];
    const result = spotify.spotifyApi.getGeneres(); //"does not exist"
    //genreStrings.append(result);
    genreStrings = result.body.genres; // Access the genres array correctly
    res.status(200).send(genreStrings); // Send the array directly
    //res.status(200).send(genreStrings.json);
  } catch (error) {
    res
      .status(500)
      .send(
        `Error at /recommendations/available-genre-seeds endpoint: ${error.message}`
      );
  }
});
//ENDPOINT FOR GETTING RECCOMENDATIONS
app.get("/recommendations", async (req, res) => {
  //Error at /recommendations endpoint: spotifyApi.getReccomendation is not a function
  try {
    const { seed_artists, seed_genres, seed_tracks } = req.query;
    const result = await spotify.spotifyApi.getReccomendation(
      seed_artists,
      seed_genres,
      seed_tracks
    ); //"does not exist"
    res.status(200).send(result.json);
  } catch (error) {
    res
      .status(500)
      .send(`Error at /recommendations endpoint: ${error.message}`);
  }
});

//ENDPOINT FOR SAVING EPISODE: ERROR 404
app.put("/me/episodes", async (req, res) => {
  //Error at /me/episodes endpoint: spotifyApi.saveEpisodeForCurrentUser is not a function
  try {
    const { ids } = req.query;
    const episodeIds = ids.split(",");
    if (episodeIds > 50) {
      return res
        .status(400)
        .send("/me/episodes has exceeded it's limit of 50 ids");
    }
    const result = spotify.spotifyApi.saveEpisodeForCurrentUser(episodeIds); //doesn't exist?
    console.log("Episode saved!");
    res.status(200).send(result.json);
  } catch (error) {
    res.status(500).send(`Error at /me/episodes endpoint: ${error.message}`);
  }
});

// const admin = require("firebase-admin");
// const serviceAccount = require("./serviceAccountKey.json");
// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount),
// });

// const db = admin.firestore();

app.get("/get-episodes/:userId", async (req, res) => {
  const { userId } = req.params;

  try {
    const snapshot = await firestore.db
      .collection("users")
      .doc(userId)
      .collection("savedEpisodes")
      .get();

    const episodes = snapshot.docs.map((doc) => doc.data());
    return res.status(200).json({ episodes });
  } catch (error) {
    console.error("Error retrieving episodes:", error);
    return res.status(500).json({ error: "Failed to retrieve episodes" });
  }
});

app.post("/save-episode/:userId", async (req, res) => {
  const { userId } = req.params;
  const episode = req.body;

  if (!userId || !episode || !episode.id) {
    return res.status(400).json({ error: "Missing userId or episode data" });
  }

  try {
    const episodeRef = firestore.db
      .collection("users")
      .doc(userId)
      .collection("savedEpisodes")
      .doc(episode.id); // Make sure your episode model uses "id"

    await episodeRef.set(episode);

    return res.status(200).json({ message: "Episode saved successfully" });
  } catch (error) {
    console.error("Error saving episode:", error);
    return res.status(500).json({ error: "Failed to save episode" });
  }
});

app.post("/remove-episode", async (req, res) => {
  const { userId, episodeId } = req.body;

  // Ensure userId and episodeId are present
  if (!userId || !episodeId) {
    return res.status(400).json({ error: "Missing userId or episodeId" });
  }

  try {
    // Reference to Firestore where the episode is saved
    const episodeRef = firestore.db
      .collection("users")
      .doc(userId)
      .collection("savedEpisodes")
      .doc(episodeId);

    // Delete the episode document
    await episodeRef.delete();

    return res.status(200).json({ message: "Episode removed successfully" });
  } catch (error) {
    console.error("Error removing episode:", error);
    return res.status(500).json({ error: "Failed to remove episode" });
  }
});

//ENDPOINT FOR REMOVING SAVED EPISODE
app.delete("/me/episodes", async (req, res) => {
  //Error at /me/episodes DELETE endpoint: spotifyApi.removeEpisodesForCurrentUser is not a function
  try {
    const { ids } = req.query;
    const episodeIds = ids.split(",");
    if (episodeIds > 50) {
      return res
        .status(400)
        .send("REMOVE FUNCTION:/me/episodes has exceeded it's limit of 50 ids");
    }
    await spotify.spotifyApi.removeEpisodesForCurrentUser(episodeIds);
    console.log("Episode removed.");
    res.status(200).send();
  } catch (error) {
    res
      .status(500)
      .send(`Error at /me/episodes DELETE endpoint: ${error.message}`);
  }
});
//SAVE TIMESTAMP FOR USER'S LISTENED PODCAST (Get Playback State)
app.get("/me/player", async (req, res) => {
  try {
    const { market, additional_types } = req.query;
    const options = {};
    if (market) {
      options.market = market;
    }
    if (additional_types) {
      options.additional_types = additional_types;
    }
    const data = await spotify.spotifyApi.getMyCurrentPlaybackState(options);
    if (!data.body) {
      //no new info is available
      res.status(204).send("Playback not available or active");
    }
    const playbackState = data.body;
    const result = await firestore.savePlaybackState(playbackState);
    console.log("Information about playback");
    res.status(200).send(result.json);
  } catch (error) {
    res.status(500).send(`Error at /me/player endpoint: ${error.message}`);
  }
});

/* ------------------------------- FIRESTORE ENDPOINTS ------------------------------- */

// ENDPOINT TO SAVE USER DATA
//   failed to start application on cscd-488-project.glitch.me

//   This is most likely because your project has a code error.
//   Check your project logs, fix the error and try again.
app.post("/save_data/:userId", async (req, res) => {
  const userId = req.params.userId;
  const { name, email, spotifyLinked } = req.body;

  console.log("Partial update request received for user:", userId);

  if (!userId) {
    return res.status(400).json({ error: "userId is required" });
  }

  // Only include fields that are provided
  const updateData = {};
  if (name !== undefined) updateData.name = name;
  if (email !== undefined) updateData.email = email;
  if (spotifyLinked !== undefined) updateData.spotifyLinked = spotifyLinked;

  if (Object.keys(updateData).length === 0) {
    return res
      .status(400)
      .json({ error: "At least one field to update is required" });
  }

  try {
    const result = await firestore.saveUserData(userId, updateData);
    res.status(200).json({ message: "User data updated", data: result });
  } catch (error) {
    console.error("Error in /save_data:", error);
    res.status(500).json({ error: error.message || "Internal Server Error" });
  }
});

app.post("/save_token/:userId", async (req, res) => {
  const { refresh_token, userId } = req.body;
  console.log("setting up save_data functionality!");
  try {
    const result = await firestore.saveUserTokens(userId, refresh_token);
    res.status(200).send(result);
  } catch (error) {
    res.status(500).send(error.message);
  }
});

// ENDPOINT TO RETRIEVE USER DATA
app.get("/get_data/:userId", async (req, res) => {
  const { userId } = req.params;
  console.log("called get_data");
  try {
    const result = await firestore.getUserData(userId);
    res.status(200).send(result);
  } catch (error) {
    res.status(500).send(error.message);
  }
});

// ENDPOINT TO DELETE USER DATA
app.get("/delete_data/:userId", async (req, res) => {
  const { userId } = req.query;
  console.log("getting delete_data functionality!");
  try {
    const result = await firestore.deleteDataFromFirestore(userId); //Function written. TO BE TESTED!!!!
    res.status(200).send(result);
  } catch (error) {
    res.status(500).send(error.message);
  }
});

//TODO: Make endpoints for the merge functions
//is the endpoint towards "/merge_data?"
app.post("/merge_data/:name", async (req, res) => {
  const { userId, name } = req.body;
  try {
    const result = await firestore.mergeUpdatedUserName(userId, name);
    res.status(200).send(result);
  } catch (error) {
    res.status(500).send(error.message);
  }
});

app.post("/merge_data/:email", async (req, res) => {
  const { userId, email } = req.body;
  try {
    const result = await firestore.mergeUpdatedUserEmail(userId, email);
    res.status(200).send(result);
  } catch (error) {
    res.status(500).send(error.message);
  }
});

app.post("/merge_data/:password", async (req, res) => {
  const { userId, password } = req.body;
  try {
    const result = await firestore.mergeUpdatedUserPassword(userId, password);
    res.status(200).send(result);
  } catch (error) {
    res.status(500).send(error.message);
  }
});
// LOCAL FUNCTIONS

/* ------------------------------- FIRESTORE FUNCTIONS ------------------------------- */
//ALL FIRESTORE FUNCTIONS HAVE BEEN MOVED TO firestore-calls.js
/* ------------------------------- SPOTIFY FUNCTIONS ------------------------------- */
//ALL SPOTIFY FUNCTIONS HAVE BEEN MOVED TO spotify-calls.js
/* --------------------------------------- TEST CODE --------------------------------------- */
// Add this below your other routes
app.post("/pause-podcast", async (req, res) => {
  const { userId } = req.body;

  if (!userId) {
    return res.status(400).json({ error: "userId is required" });
  }

  try {
    const { accessToken, refreshToken } = await firestore.getUserTokens(userId);
    if (!accessToken || !refreshToken) {
      return res.status(401).json({ error: "Missing tokens for user" });
    }

    //spotify.spotifyApi.setAccessToken(accessToken);
    spotify.spotifyApi.setRefreshToken(refreshToken);

    try {
      await spotify.spotifyApi.pause();
      return res.status(200).json({ message: "Playback paused" });
    } catch (err) {
      if (err.statusCode === 401) {
        // Token expired
        const data = await spotify.spotifyApi.refreshAccessToken();
        const newAccessToken = data.body.access_token;

        await firestore.saveUserTokens(userId, refreshToken, newAccessToken);
        spotify.spotifyApi.setAccessToken(newAccessToken);

        await spotify.spotifyApi.pause();
        return res
          .status(200)
          .json({ message: "Playback paused after refresh" });
      }

      console.error("Pause error:", err.message);
      return res.status(err.statusCode || 500).json({ error: err.message });
    }
  } catch (error) {
    console.error("Internal error:", error.message);
    return res.status(500).json({ error: "Internal server error" });
  }
});

app.post("/seek-podcast", async (req, res) => {
  const { userId, offsetMs } = req.body;

  if (!userId || typeof offsetMs !== "number") {
    return res.status(400).json({ error: "userId and offsetMs are required" });
  }

  try {
    const { accessToken, refreshToken } = await firestore.getUserTokens(userId);
    if (!accessToken || !refreshToken) {
      return res.status(401).json({ error: "Missing tokens for user" });
    }

    //spotify.spotifyApi.setAccessToken(accessToken);
    spotify.spotifyApi.setRefreshToken(refreshToken);

    try {
      // Get current playback position
      const playback = await spotify.spotifyApi.getMyCurrentPlaybackState();
      const currentPosition = playback.body?.progress_ms;

      if (currentPosition == null) {
        return res.status(400).json({ error: "Nothing is currently playing" });
      }

      const newPosition = currentPosition + offsetMs;

      await spotify.spotifyApi.seek(newPosition);
      return res.status(200).json({ message: `Seeked to ${newPosition}ms` });
    } catch (err) {
      if (err.statusCode === 401) {
        const refreshed = await spotify.spotifyApi.refreshAccessToken();
        const newAccessToken = refreshed.body.access_token;
        await firestore.saveUserTokens(userId, refreshToken, newAccessToken);

        spotify.spotifyApi.setAccessToken(newAccessToken);

        const playback = await spotify.spotifyApi.getMyCurrentPlaybackState();
        const currentPosition = playback.body?.progress_ms;
        const newPosition = currentPosition + offsetMs;

        await spotify.spotifyApi.seek(newPosition);
        return res
          .status(200)
          .json({ message: `Seeked to ${newPosition}ms after token refresh` });
      }

      console.error("Seek error:", err.message);
      return res.status(err.statusCode || 500).json({ error: err.message });
    }
  } catch (error) {
    console.error("Internal error:", error.message);
    return res.status(500).json({ error: "Internal server error" });
  }
});

app.post("/get-podcast-status", async (req, res) => {
  const { userId } = req.body;

  if (!userId) {
    return res.status(400).json({ error: "userId is required" });
  }

  try {
    const { accessToken, refreshToken } = await firestore.getUserTokens(userId);
    if (!accessToken || !refreshToken) {
      return res.status(401).json({ error: "Missing tokens for user" });
    }

    //spotify.spotifyApi.setAccessToken(accessToken);
    spotify.spotifyApi.setRefreshToken(refreshToken);

    const getPlaybackOrRecent = async () => {
      const playback = await spotify.spotifyApi.getMyCurrentPlaybackState();

      if (playback.body && playback.body.item) {
        const item = playback.body.item;
        return {
          type: "currently_playing",
          name: item.name,
          id: item.id,
          image: item.album?.images?.[0]?.url || null,
          progress_ms: playback.body.progress_ms || 0,
          duration_ms: item.duration_ms || 0,
        };
      }

      const recent = await spotify.spotifyApi.getMyRecentlyPlayedTracks({
        limit: 1,
      });

      const last = recent.body.items?.[0];
      if (last && last.track) {
        return {
          type: "last_played",
          name: last.track.name,
          id: last.track.id,
          image: last.track.album?.images?.[0]?.url || null,
          played_at: last.played_at,
          duration_ms: last.track.duration_ms,
        };
      }

      return null;
    };

    try {
      const result = await getPlaybackOrRecent();
      if (!result) {
        return res.status(200).json({
          playing: false,
          message: "No current or recent playback found.",
        });
      }

      return res
        .status(200)
        .json({ playing: result.type === "currently_playing", ...result });
    } catch (err) {
      if (err.statusCode === 401) {
        // Refresh token and retry
        const refreshed = await spotify.spotifyApi.refreshAccessToken();
        const newAccessToken = refreshed.body.access_token;
        await firestore.saveUserTokens(userId, refreshToken, newAccessToken);

        spotify.spotifyApi.setAccessToken(newAccessToken);
        const result = await getPlaybackOrRecent();

        if (!result) {
          return res.status(200).json({
            playing: false,
            message: "No current or recent playback found.",
          });
        }

        return res
          .status(200)
          .json({ playing: result.type === "currently_playing", ...result });
      }

      console.error("Spotify API error:", JSON.stringify(err, null, 2));

      const errorMessage =
        err.body?.error?.message || err.message || "Unknown Spotify API error";

      return res
        .status(err.statusCode || 500)
        .json({ error: errorMessage, raw: err.body || err });
    }
  } catch (error) {
    console.error("Server error:", error.message);
    return res.status(500).json({ error: "Internal server error" });
  }
});

app.post("/play-podcast", async (req, res) => {
  const { episodeUri, userId } = req.body;

  if (!episodeUri || !userId) {
    return res
      .status(400)
      .json({ error: "episodeUri and userId are required" });
  }

  try {
    // Get user's tokens
    const { accessToken, refreshToken } = await firestore.getUserTokens(userId);
    if (!accessToken || !refreshToken) {
      return res.status(401).json({ error: "Missing tokens for user" });
    }

    //spotify.spotifyApi.setAccessToken(accessToken);
    spotify.spotifyApi.setRefreshToken(refreshToken);

    try {
      // Try playing the episode
      await spotify.spotifyApi.play({
        uris: [episodeUri],
      });
      return res.status(200).json({ message: "Playback started" });
    } catch (err) {
      if (err.statusCode === 401) {
        // Token expired, refresh it
        console.log("Access token expired. Refreshing...");
        const data = await spotify.spotifyApi.refreshAccessToken();
        const newAccessToken = data.body.access_token;

        // Save and retry
        await firestore.saveUserTokens(userId, refreshToken, newAccessToken);
        spotify.spotifyApi.setAccessToken(newAccessToken);

        await spotify.spotifyApi.play({
          uris: [episodeUri],
        });

        return res
          .status(200)
          .json({ message: "Playback started after token refresh" });
      }

      console.error("Playback failed:", err.message);
      return res.status(err.statusCode || 500).json({ error: err.message });
    }
  } catch (error) {
    console.error("Internal error:", error.message);
    return res.status(500).json({ error: "Internal server error" });
  }
});

app.get("/api/podcast-details/:userId", async (req, res) => {
  const { userId } = req.params;
  const { query } = req.query;

  if (!query) {
    return res.status(400).json({ error: "Search query is required" });
  }

  try {
    const podcasts = await getPodcastDetails(spotify.spotifyApi, query, userId);
    res.json(podcasts);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

async function getPodcastDetails(spotifyApi, searchQuery, userId) {
  try {
    if (!searchQuery || typeof searchQuery !== "string") {
      throw new Error(
        `Invalid search query: Search query must be a non-empty string. Provided: ${searchQuery}`
      );
    }

    if (!userId) {
      throw new Error("User ID is required for authentication.");
    }

    console.log("Searching podcasts with query:", searchQuery);

    let { refreshToken, accessToken } = await firestore.getUserTokens(userId);
    if (!accessToken || !refreshToken) {
      throw new Error(
        `Missing tokens for user ${userId}. Tokens are required to proceed.`
      );
    }

    //spotifyApi.setAccessToken(accessToken);
    spotifyApi.setRefreshToken(refreshToken);

    try {
      const response = await spotifyApi.searchShows(searchQuery, {
        market: "US",
      });
      return processPodcastResponse(response);
    } catch (error) {
      console.warn("Access token expired, refreshing token...");

      try {
        const refreshedData = await spotifyApi.refreshAccessToken();
        const newAccessToken = refreshedData.body.access_token;

        console.log("New access token received:", newAccessToken);

        await firestore.saveUserTokens(userId, refreshToken, newAccessToken);
        spotifyApi.setAccessToken(newAccessToken);

        console.log("Retrying search with new access token...");
        const retryResponse = await spotifyApi.searchShows(searchQuery, {
          market: "US",
        });
        return processPodcastResponse(retryResponse);
      } catch (refreshError) {
        throw new Error(
          `Failed to refresh access token for user ${userId}: ${refreshError.message}`
        );
      }
    }
  } catch (error) {
    console.error("Error in getPodcastDetails:", {
      message: error.message,
      searchQuery,
      userId,
      stack: error.stack,
    });

    if (error instanceof Error) {
      throw new Error(
        `Error in getPodcastDetails for user ${userId} with search query "${searchQuery}": ${error.message}`
      );
    } else {
      throw new Error(
        `Unknown error while searching podcasts for user ${userId} with search query "${searchQuery}": ${JSON.stringify(
          error
        )}`
      );
    }
  }
}

function processPodcastResponse(response) {
  if (!response?.body?.shows?.items) {
    throw new Error("Invalid API response - missing shows data");
  }

  const items = response.body.shows.items;
  if (!Array.isArray(items) || items.length === 0) {
    return [];
  }

  return items.map((show) => ({
    id: show.id || "unknown",
    name: show.name || "Unnamed Podcast",
    description: show.description || "",
    publisher: show.publisher || "Unknown Publisher",
    totalEpisodes: show.total_episodes || 0,
    image: show.images?.[0]?.url || "",
  }));
}
/* --------------------------------------- TEST CODE --------------------------------------- */
const MOOD_QUERY_EXPANSIONS = {
  happy: ["uplifting", "comedy", "feel good", "optimism", "funny", "positive"],
  sad: ["comfort", "healing", "mindfulness", "mental health", "grief", "calm"],
  angry: ["calm", "stoic", "decompression", "focus", "resilience"],
  anxious: ["anxiety relief", "mindfulness", "breathing", "calm talk", "meditation"],
  tired: ["light conversation", "storytelling", "gentle", "easy listening"],
  focused: ["deep work", "productivity", "learning", "analysis", "business"],
  excited: ["high energy", "trending", "sports talk", "tech news", "pop culture"],
  scared: ["calming", "comfort", "mindfulness", "safety", "grounding"],
  investing: ["markets", "stocks", "finance", "economy", "business news"],
  motivation: ["self improvement", "discipline", "goals", "mindset", "success"],
  nostalgia: ["retro", "throwback", "history", "classic stories", "memories"],
  science: ["space", "physics", "biology", "technology", "research"],
  calming: ["sleep", "relaxation", "meditation", "breathwork", "soft spoken"],
};

function normalizeText(value) {
  if (typeof value !== "string") {
    return "";
  }

  return value.toLowerCase();
}

function tokenize(value) {
  return normalizeText(value)
    .replace(/[^a-z0-9\s]/g, " ")
    .split(/\s+/)
    .filter((token) => token.length >= 3);
}

function parseEteMinutes(rawEteMinutes) {
  const parsed = Number(rawEteMinutes);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return null;
  }

  return Math.min(parsed, 180);
}

function getMoodExpansionTerms(mood) {
  const normalizedMood = normalizeText(mood).trim();
  const moodTerms = MOOD_QUERY_EXPANSIONS[normalizedMood] || [];
  const genericTerms = ["podcast", "episode"];
  return [...new Set([normalizedMood, ...moodTerms, ...genericTerms])].filter(
    Boolean
  );
}

function buildDiscoveryQueries(mood, preferredTerms = []) {
  const moodTerms = getMoodExpansionTerms(mood);
  const preferred = preferredTerms.slice(0, 6);

  const seededQueries = [
    `${mood} podcast episode`,
    ...moodTerms.slice(0, 6).map((term) => `${term} podcast episode`),
    ...preferred.map((term) => `${mood} ${term} podcast`),
    ...preferred.slice(0, 3).map((term) => `${term} interview podcast`),
  ];

  return [...new Set(seededQueries)].slice(0, 12);
}

async function ensureSpotifyClientToken() {
  const data = await spotify.spotifyApi.clientCredentialsGrant();
  spotify.spotifyApi.setAccessToken(data.body["access_token"]);
}

async function searchPodcastEpisodes(query, limit = 30) {
  const searchResults = await spotify.spotifyApi.search(query, ["episode"], {
    limit,
    market: "US",
  });

  return searchResults?.body?.episodes?.items || [];
}

async function collectCandidateEpisodes(queries) {
  const searchRuns = await Promise.allSettled(
    queries.map((query) => searchPodcastEpisodes(query, 35))
  );

  const deduped = new Map();
  for (const run of searchRuns) {
    if (run.status !== "fulfilled") {
      continue;
    }

    for (const episode of run.value) {
      if (!episode?.id) {
        continue;
      }

      if (!deduped.has(episode.id)) {
        deduped.set(episode.id, episode);
      }
    }
  }

  return [...deduped.values()];
}

function buildEpisodeText(episode) {
  return [
    episode?.name,
    episode?.description,
    episode?.show?.name,
    episode?.show?.publisher,
  ]
    .filter(Boolean)
    .join(" ");
}

function getEpisodeDurationMinutes(episode) {
  if (!episode?.duration_ms || !Number.isFinite(episode.duration_ms)) {
    return null;
  }

  return episode.duration_ms / 60000;
}

function getDurationFitScore(episode, eteMinutes) {
  if (!eteMinutes) {
    return 0.5;
  }

  const durationMinutes = getEpisodeDurationMinutes(episode);
  if (!durationMinutes) {
    return 0.2;
  }

  const distance = Math.abs(durationMinutes - eteMinutes);
  const tolerance = Math.max(8, eteMinutes * 0.4);
  const score = 1 - distance / (tolerance * 2);
  return Math.max(0, Math.min(1, score));
}

function getRecencyScore(episode) {
  if (!episode?.release_date) {
    return 0.25;
  }

  const releaseDate = new Date(episode.release_date);
  if (Number.isNaN(releaseDate.getTime())) {
    return 0.25;
  }

  const ageInDays =
    (Date.now() - releaseDate.getTime()) / (1000 * 60 * 60 * 24);

  if (ageInDays < 30) return 1;
  if (ageInDays < 180) return 0.8;
  if (ageInDays < 365) return 0.6;
  if (ageInDays < 730) return 0.4;
  return 0.2;
}

function shouldKeepEpisode(episode, excludedIds) {
  if (!episode?.id || excludedIds.has(episode.id)) {
    return false;
  }

  if (episode?.type && episode.type !== "episode") {
    return false;
  }

  if (episode?.is_playable === false) {
    return false;
  }

  return true;
}

function scoreEpisode(episode, context) {
  const {
    moodTermsSet,
    preferredTermsSet,
    preferredShowTermsSet,
    eteMinutes,
  } = context;

  const combinedText = buildEpisodeText(episode);
  const tokenSet = new Set(tokenize(combinedText));

  let moodHits = 0;
  for (const term of moodTermsSet) {
    if (term.includes(" ")) {
      if (normalizeText(combinedText).includes(term)) {
        moodHits += 1;
      }
      continue;
    }

    if (tokenSet.has(term)) {
      moodHits += 1;
    }
  }

  let preferredHits = 0;
  for (const term of preferredTermsSet) {
    if (tokenSet.has(term)) {
      preferredHits += 1;
    }
  }

  const showName = normalizeText(episode?.show?.name || "");
  let showAffinity = 0;
  for (const term of preferredShowTermsSet) {
    if (showName.includes(term)) {
      showAffinity += 1;
    }
  }

  const moodScore = Math.min(1, moodHits / Math.max(1, moodTermsSet.size));
  const preferenceScore = Math.min(1, preferredHits / 6);
  const showAffinityScore = Math.min(1, showAffinity / 2);
  const durationFit = getDurationFitScore(episode, eteMinutes);
  const recencyScore = getRecencyScore(episode);
  const explicitPenalty = episode?.explicit ? 0.15 : 0;

  const qualityScore =
    (episode?.audio_preview_url ? 0.08 : 0) +
    (episode?.language === "en" ? 0.05 : 0) +
    (episode?.show?.publisher ? 0.04 : 0);

  return (
    moodScore * 0.42 +
    durationFit * 0.24 +
    preferenceScore * 0.14 +
    showAffinityScore * 0.08 +
    recencyScore * 0.1 +
    qualityScore -
    explicitPenalty
  );
}

function rerankEpisodes(episodes, mood, eteMinutes, discoverySignals) {
  const preferredTerms = discoverySignals?.preferredTerms || [];
  const preferredShowTerms = preferredTerms.filter((term) => term.length >= 4);
  const moodTermsSet = new Set(getMoodExpansionTerms(mood).flatMap(tokenize));

  return episodes
    .map((episode) => ({
      episode,
      score: scoreEpisode(episode, {
        moodTermsSet,
        preferredTermsSet: new Set(preferredTerms),
        preferredShowTermsSet: new Set(preferredShowTerms),
        eteMinutes,
      }),
    }))
    .sort((a, b) => b.score - a.score)
    .map((item) => item.episode);
}

async function getPodcastEpisodes({ mood, eteMinutes, discoverySignals }) {
  const queries = buildDiscoveryQueries(mood, discoverySignals?.preferredTerms);
  const candidateEpisodes = await collectCandidateEpisodes(queries);

  const excludedIds = new Set([
    ...(discoverySignals?.blockedEpisodeIds || []),
    ...(discoverySignals?.savedEpisodeIds || []),
    ...(discoverySignals?.favoriteEpisodeIds || []),
  ]);

  const filteredEpisodes = candidateEpisodes.filter((episode) =>
    shouldKeepEpisode(episode, excludedIds)
  );

  const noExclusions = new Set();
  const episodesToRank =
    filteredEpisodes.length > 0
      ? filteredEpisodes
      : candidateEpisodes.filter((episode) =>
          shouldKeepEpisode(episode, noExclusions)
        );

  const rerankedEpisodes = rerankEpisodes(
    episodesToRank,
    mood,
    eteMinutes,
    discoverySignals
  );

  return rerankedEpisodes.slice(0, 24);
}

const openAIFilter = async (podcastDetails, mood) => {
  const limitedDetails = podcastDetails.slice(0, 10).map((podcast) => ({
    id: podcast.id,
    description:
      podcast.description.slice(0, 100) +
      (podcast.description.length > 100 ? "..." : ""),
  }));

  try {
    const requestBody = {
      model: "gpt-4o",
      messages: [
        {
          role: "system",
          content:
            "Analyze an array of Spotify podcast episode details (max 10) with descriptions (~100 chars) and return an array of podcast IDs matching a mood (happy, sad, greedy). For 'happy', seek positive/fun themes; for 'sad', melancholic/emotional; for 'greedy', money/wealth. Return empty array if no matches. Make sure the Episodes are not 18+ adult content...",
        },
        {
          role: "user",
          content: `Mood: ${mood}\nPodcast Details: ${JSON.stringify(
            limitedDetails
          )}`,
        },
      ],
      tools: [
        {
          type: "function",
          function: {
            name: "match_podcast_ids_by_mood",
            description: "Returns array of podcast IDs matching the mood",
            parameters: {
              type: "object",
              properties: {
                podcastIds: {
                  type: "array",
                  items: { type: "string" },
                  description: "Array of podcast IDs matching the mood",
                },
              },
              additionalProperties: false,
              required: ["podcastIds"],
            },
          },
        },
      ],
      tool_choice: {
        type: "function",
        function: { name: "match_podcast_ids_by_mood" },
      },
    };

    const response = await axios.post(
      "https://api.openai.com/v1/chat/completions",
      requestBody,
      {
        headers: {
          Authorization: `Bearer ${OPENAI_API_KEY}`,
          "Content-Type": "application/json",
        },
      }
    );

    const toolOutput =
      response.data.choices[0]?.message?.tool_calls?.[0]?.function?.arguments;
    if (!toolOutput) {
      throw new Error("No structured response received from OpenAI.");
    }

    const { podcastIds } = JSON.parse(toolOutput);
    console.log(`Podcast IDs matching ${mood} mood:`, podcastIds);
    return podcastIds;
  } catch (error) {
    console.error("Error matching podcasts by mood:", error);
    throw error;
  }
};

// SERVER
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
