/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onRequest, onCall, HttpsError} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

exports.helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

// Callable function
exports.triggerAdd = onCall((request) => {

  const data = request.data;

  const a = data.a;
  const b = data.b;

  const result = a + b;

  return {
    message: "Addition successful",
    result: result
  };
});

// Send Notification

exports.sendPushNotification = onCall(async (request) => {
  const { token, title, body } = request.data;

  if (!token || !title || !body) {
    throw new HttpsError(
      "invalid-argument",
      "token, title, and body are required"
    );
  }

  const messageId = await admin.messaging().send({
    token,
    notification: {
      title,
      body,
    },
    android: {
      priority: "high",
      notification: {
        channelId: "high_importance_channel",
      },
    },
  });

  return {
    success: true,
    messageId,
  };
});