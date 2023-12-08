import React, { useState } from "react";
// importing principal datatype which is similar to importing principle in .mo library but in JS
import { Principal } from '@dfinity/principal';
import { token_backend } from "../../../declarations/token_backend";

function Balance() {

  const [inputValue, setInput] = useState("");
  const [balanceResult, setBalance] = useState("");
  const [cryptoSymbol, setSymbol] = useState("");
  const [isHidden, setHidden] = useState(true);
  
  async function handleClick() {
    // console.log("balance button clicked");
    const principal = Principal.fromText(inputValue);
    const balance = await token_backend.balanceOf(principal);
    
    // balance you got from the backend is a Nat type. In order to set it to string:
    setBalance(balance.toLocaleString());
    setSymbol(await token_backend.getSymbol());
    setHidden(false);
  }


  return (
    <div className="window white">
      <label>Check account token balance:</label>
      <p>
        <input
          id="balance-principal-id"
          type="text"
          placeholder="Enter a Principal ID"
          value={inputValue}
          onChange={(e) => setInput(e.target.value)}
        />
      </p>
      <p className="trade-buttons">
        <button
          id="btn-request-balance"
          onClick={handleClick}
        >
          Check Balance
        </button>
      </p>
      <p hidden={isHidden}>This account has a balance of {balanceResult} {cryptoSymbol}.</p>
    </div>
  );
}

export default Balance;
