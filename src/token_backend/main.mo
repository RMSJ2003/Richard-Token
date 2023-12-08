import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
// dfx deploy won't work if there is no actor/class here.

actor Token {

  Debug.print("Ay sorry");
  // The owner
  // Principal.fromText converts text into a principal data type.
  // The text is the principal ID of user who is assigned to the token, in this case owner.
  // Principal docs: https://internetcomputer.org/docs/current/motoko/main/base/Principal/#type-principal
  let owner : Principal = Principal.fromText("fwqby-jsttt-twdtn-pgbc5-bke3n-mqj5e-omjwi-e3fij-zmf4y-tentt-dae");
  let totalSupply : Nat = 1000000000; // Token Supply
  let symbol : Text = "CHAD"; // Token Abbrevation

  // Temporary variable will have stable type. Before the code
  // gets upgraded, we transfer the data into the temporary variable
  // then after the upgrade, we transfer the data back.
  // balanceEntries is only accesible within the Token actor, no other file, canister, or class can
  private stable var balanceEntries : [(Principal, Nat)] = [];

  // Creating the ledger.
  // HashMap.HashMap<Key's datatype, Value's datatype>
  // () after that means initialize that new HashMap
  // ()'s 1st param is the initial size of the HashMap
  // 2nd param is how are we going to check for the equality of our keys? if principal = balance or
  // other words it checks if the principal is really the one who owns the  balance.
  // 3rd param is how HashMap should hash the keys which are Principal data type.
  // Associates princial ID and amount of CHAD token that the ID owns
  // Note: HashMap is a non-stable type. 
  // balances is only accesible within the Token actor, no other file, canister, or class can
  private var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);
  // Checks if the balances is empty. If yes then the owner gets all the totalSupply
  // as the only key and value inside the balances HashMap.
  // We want there to be an initial balance and the owner
  // even if I haven't gone through upgrade so I put this here too.
  if (balances.size() < 1) balances.put(owner, totalSupply);

  // Check Balance method
  // who: Principal means who has a data type of Principal
  public query func balanceOf(who : Principal) : async Nat {

    // Checks the outcome of balances.get(who) and we'll get the value
    // how much currency they own.
    let balance : Nat = switch (balances.get(who)) {
      // .get docs: https://internetcomputer.org/docs/current/samples/persistent-storage/#get
      case null 0;
      // if the outcome is optional result then it returns the result wihout optional (?)
      case (?result) result;
    };

    return balance;
  };

  public query func getSymbol() : async Text {
    return symbol;
  };

  // Claim free CHAD tokens: Faucet

  // Successful faucet of amount to the user.
  public shared (msg) func payOut() : async Text {
    Debug.print(debug_show(msg.caller));
    // Checks if the user already claim his one time free claim and already exists in our ledger (balances variable)
    if (balances.get(msg.caller) == null) {
      // Give 10000 CHAD whoever calls this function.
      let amount = 10000;
      // Transfer the amount to the user
      let result = await transfer(msg.caller, amount); 
      return result;
    } else {
      return "Already Claimed";
    };
  };

  public shared (msg) func transfer(to : Principal, amount : Nat) : async Text {
    let fromBalance = await balanceOf(msg.caller);
    Debug.print(debug_show(msg.caller));
    if (fromBalance > amount) {
      // We put Nat becuase of this warning: operator may trap for inferred type NatMotoko(M0155)
      let newFromBalance : Nat = fromBalance - amount;
      balances.put(msg.caller, newFromBalance);

      let toBalance = await  balanceOf(to);
      let newToBalance = toBalance + amount;
      balances.put(to, newToBalance);

      return "Success";
    } else {
      return "Insufficient Funds";
    };
  };

  // Saving data in an stable array in preupgrade.
  system func preupgrade() {
    // Docs: https://internetcomputer.org/docs/current/motoko/main/base/Iter/#function-fromarray
    // balance isn't iteratable itself so we use .entries() to make it iteratable.
    balanceEntries := Iter.toArray(balances.entries());
  };
  // Extracting data from the array in postupgrade.
  system func postupgrade() {
    // () after > means calling fromIter
    // starting from the 2nd param, you just supply the same arguments
    // that we did when we created our HashMap.
    balances := HashMap.fromIter<Principal, Nat>(balanceEntries.vals(), 1, Principal.equal, Principal.hash);

    // Checks if the balances is empty. If yes then the owner gets all the totalSupply
    // as the only key and value inside the balances HashMap.
    if (balances.size() < 1) balances.put(owner, totalSupply);
  };
};
