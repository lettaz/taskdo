// Helper function to set a Bearer token in Swagger UI
window.setApiToken = function(token) {
  if (!token) {
    console.error("No token provided");
    return;
  }
  
  // Format token if needed
  if (!token.startsWith("Bearer ")) {
    token = "Bearer " + token;
  }
  
  // Try to set the token in Swagger UI's auth mechanism
  try {
    const authActions = window.ui.getSystem().authActions;
    authActions.authorize({
      BearerAuth: {
        name: "BearerAuth",
        schema: { type: "http", scheme: "bearer" },
        value: token
      }
    });
    console.log("Token set successfully");
  } catch (e) {
    console.error("Failed to set token:", e);
  }
} 