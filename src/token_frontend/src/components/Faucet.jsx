import React, { useState } from "react";
// canisterId and createActor comes from declarations/token_backend/index.js
import { token_backend, canisterId, createActor } from "../../../declarations/token_backend";
import { AuthClient } from "@dfinity/auth-client";

function Faucet() {
  const [isDisabled, setDisable] = useState(false);
  const [buttonText, setText] = useState("Gimme gimme");

  async function handleClick(event) {
    setDisable(true);
    // Create authClient object
    const authClient = await AuthClient.create();
    // Once it'b been created and we've gotten this authClient back
    // , then we can use it to get the identity of the authenticated user.
    const identity = await authClient.getIdentity();
    // Now we can use this identity that we get back
    // to create an actor. It's going to take the 
    // canister id, which is an environment variable
    // that contains the principal id of the canister.
    // This createActor can take some agent options
    // where we can supply the identity of the authenticated user.
    // I am going to supply the canisterId by using the environment variable 
    // canisterId that we imported. And I going to supply an object.
    const authenticatedCanister = createActor(canisterId, {
      // This object is going to be the options for creating this actor or canister.
      agentOptions: {
        identity,
      }, 
    });
    // Now it's with authenticatedCanister we're going to call the payOut.
    // When it gets to the backend's payOut method, the msg.caller will then
    // be the principal ID of the authenticated user. And it's that authenticated
    // user who's going to be getting the token transfer.
    // NOTE: IN ORDER FOR THIS TO WORK, YOU MUST DEPLOY IT TO THE LIVE BLOCKCHAIN
    // AS THIS AUTHENTICATION PROCESS DOEN'T WORK IN LOCAL DEVELOPMENT.
    const result = await authenticatedCanister.payOut();

    setText(result);
  }

  return (
    <div className="blue window">
      <h2>
        <span role="img" aria-label="tap emoji">
          🚰
        </span>
        Faucet
      </h2>
      <label>Get your free Richard tokens here! Claim 10,000 CHAD tokens to your account.</label>
      <p className="trade-buttons">
        <button id="btn-payout" onClick={handleClick} disabled={isDisabled}>
          {buttonText}
        </button>
      </p>
    </div>
  );
}

export default Faucet;
