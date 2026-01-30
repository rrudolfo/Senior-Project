const spotifyWebApi = require("spotify-web-api-node");
const spotifyApi = new spotifyWebApi({
  clientId: process.env.SPOTIFY_CLIENT_ID,
  clientSecret: process.env.SPOTIFY_CLIENT_SECRET,
  redirectUri: process.env.SPOTIFY_REDIRECT_URI,
});

const scopes = [
   "user-read-private",
   "user-read-email",
   "user-top-read",
   "user-read-playback-position",
   "user-read-playback-state",
   "user-library-modify",
   "playlist-modify-public",
   "playlist-modify-private"
 ];

//IMPORT EXTENSION FOR FIRESTORE FUNCTION(S) FILE
const firestore = require("./firestore-calls");


async function getClientCredentialsToken(refreshToken = null) {
  try {
    if (refreshToken) {
      console.log("Attempting to refresh the access token...");
      const access_token = await refreshAccessToken(refreshToken);
      console.log("Setting the refreshed access token.");
      spotifyApi.setAccessToken(access_token);
    } else {
      console.log("Getting new client credentials token...");
      const data = await spotifyApi.clientCredentialsGrant();
      const accessToken = data.body["access_token"];
      spotifyApi.setAccessToken(accessToken);
      console.log("Setting the new access token.");
    }
  } catch (error) {
    console.error("Error retrieving or refreshing the access token:", error);
    throw new Error("Failed to retrieve or refresh access token.");
  }
}

async function refreshAccessToken(refreshToken) {
  try {
    spotifyApi.setRefreshToken(refreshToken);

    const data = await spotifyApi.refreshAccessToken();
    const newAccessToken = data.body["access_token"];
    const newRefreshToken = data.body["refresh_token"];

    if (newRefreshToken) {
      console.log("New refresh token:", newRefreshToken);
    }

    spotifyApi.setAccessToken(newAccessToken);

    console.log("The new access token has been retrieved successfully.");
    return newAccessToken;
  } catch (error) {
    console.error("Error refreshing the access token:", error);
    throw new Error("Failed to refresh access token.");
  }
}
//For getting the authorization header for any future request
async function getAuthorizationHeader(refreshToken) {
  return {"Authorization": "Bearer " + refreshToken};
}
//fetch the user's profile info
async function fetchProfile(token) {
    const result = await fetch("https://api.spotify.com/v1/me", {
        method: "GET", headers: { Authorization: `Bearer ${token}` }
    });

    return await result.json();
}
//If we wish to show the user's profile info on-screen to confirm their profile:
function populateUI(profile) {
    document.getElementById("displayName").innerText = profile.display_name;
    if (profile.images[0]) {
        const profileImage = new Image(200, 200);
        profileImage.src = profile.images[0].url;
        document.getElementById("avatar").appendChild(profileImage);
        document.getElementById("imgUrl").innerText = profile.images[0].url;
    }
    document.getElementById("id").innerText = profile.id;
    document.getElementById("email").innerText = profile.email;
    document.getElementById("uri").innerText = profile.uri;
    document.getElementById("uri").setAttribute("href", profile.external_urls.spotify);
    document.getElementById("url").innerText = profile.href;
    document.getElementById("url").setAttribute("href", profile.href);
    console.log(`Hey, ${profile.display_name}. Is this you?`);
}

async function fetchWebApi(userId, endpoint, method, body) {
  try {
    const token = await firestore.getUserTokens(userId);//TODO: connect this function
    const res = await fetch(`https://api.spotify.com/${endpoint}`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
      method,
      body: JSON.stringify(body),
    });
    return await res.json();
  } catch (error) {
    throw new Error(`Failed to call the spotify API: ${error.message}`);
  }
}

//EXPORT FUNCTIONS TO BE UTILIZED IN OTHER NODEJS FILES
module.exports = {
  spotifyApi,
  getClientCredentialsToken,
  refreshAccessToken,
  getAuthorizationHeader,
  fetchProfile,
  fetchWebApi
};