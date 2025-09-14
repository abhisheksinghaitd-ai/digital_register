const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendPushMessage = functions.https.onCall(async (data, context) => {
  const token = data.token;
  const title = data.title;
  const body = data.body;

  const message = {
    token: token,
    notification: {
      title: title,
      body: body
    }
  };

  try {
    await admin.messaging().send(message);
    return { success: true };
  } catch (error) {
    console.error("Error sending message:", error);
    return { success: false, error: error };
  }
});
