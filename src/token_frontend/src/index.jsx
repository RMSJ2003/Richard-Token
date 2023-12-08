import { AuthClient } from "@dfinity/auth-client";
import ReactDOM from 'react-dom'
import React from 'react'
import App from "./components/App";

const init = async () => { 
  // Create authClient object
  const authClient = await AuthClient.create();

  // Checks if the user is already authenticated
  if (await authClient.isAuthenticated()) {
    console.log("logged in");
  }

  await authClient.login({
    // Who is the identityProvider:
    // The identityProvider is going to be a URL that points
    // to the identity service on the Internet Computer, which
    // basically provides the frontend for our login purposes so
    // that we don't have to create it ourselves.
    identityProvider: "https://identity.ic0.app/#authorize",
    // What should happen once the log in was successful
    onSuccess: () => {
      // Once they have succesfully authenticated, is just to take our main app.
      ReactDOM.render(<App />, document.getElementById("root"));
    }
  });
}

init();