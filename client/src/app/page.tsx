"use client";

import { useEffect, useState } from "react";
import Web3 from "web3";
import abi from "../abi.json";
import type { Contract } from "web3-eth-contract";
import { MetaMaskInpageProvider } from "@metamask/providers";

const CONTRACT_ADDRESS = "0xD46558444E3E95225c987c5a51fDF8f78CB85C43";

declare global {
  interface Window {
    ethereum?: MetaMaskInpageProvider;
  }
}

export default function Game() {
  const [web3, setWeb3] = useState<Web3 | null>(null);
  const [contract, setContract] = useState<Contract<typeof abi.abi> | null>(
    null
  );
  const [account, setAccount] = useState("");
  const [playerMove, setPlayerMove] = useState<string | null>(null);
  const [computerMove, setComputerMove] = useState<string | null>(null);
  const [result, setResult] = useState("");
  const [contractBalance, setContractBalance] = useState("0");
  const [loading, setLoading] = useState(false);
  const [betAmount, setBetAmount] = useState<number>(0.001);

  const moves = ["Rock", "Paper", "Scissors"];

  useEffect(() => {
    async function init() {
      if (window.ethereum) {
        try {
          const web3Instance = new Web3(window.ethereum);
          console.log("Web3 initialized:", web3Instance);
          setWeb3(web3Instance);
          const contractInstance = new web3Instance.eth.Contract(
            abi.abi,
            CONTRACT_ADDRESS
          );
          setContract(contractInstance);
          await fetchContractBalance(contractInstance, web3Instance);
        } catch (error) {
          console.error("Error initializing Web3:", error);
        }
      } else {
        alert("MetaMask not installed!");
      }
    }
    init();
  }, []);

  async function fetchContractBalance(
    contractInstance: Contract<typeof abi.abi>,
    web3Instance: Web3
  ): Promise<void> {
    try {
      const balance = await contractInstance.methods
        .getContractBalance()
        .call();

      if (balance !== undefined) {
        const balanceString = balance.toString();
        setContractBalance(web3Instance.utils.fromWei(balanceString, "ether"));
      } else {
        console.error("Failed to fetch contract balance.");
      }
    } catch (error) {
      console.error("Error fetching contract balance:", error);
    }
  }

  async function connectWallet() {
    if (!window.ethereum) {
      return alert("MetaMask not installed!");
    }
    try {
      const accounts = (await window.ethereum.request({
        method: "eth_requestAccounts",
      })) as string[];
      if (accounts && accounts.length > 0) {
        setAccount(accounts[0] as string);
      } else {
        console.error("No accounts found.");
      }
    } catch (error) {
      console.error("Error connecting wallet:", error);
    }
  }

  interface PlayGameEvent {
    returnValues: {
      playerMove: number;
      computerMove: number;
      result: string;
    };
  }

  async function playGame(move: number): Promise<void> {
    if (!account) return alert("Connect Wallet First!");
    if (!contract) return alert("Contract not initialized!");

    setPlayerMove(moves[move]);
    setLoading(true);

    try {
      const tx = await contract.methods.playGame(move).send({
        from: account,
        value: web3!.utils.toWei(betAmount.toString(), "ether"),
      });

      console.log("Transaction:", tx);

      if (tx.events && tx.events.GamePlayed) {
        const event = tx.events.GamePlayed;
        const { computerMove, result } =
          event.returnValues as PlayGameEvent["returnValues"];
        setComputerMove(moves[computerMove]);
        setResult(result);
      } else {
        setResult("Game result not found in transaction logs.");
      }

      await fetchContractBalance(contract, web3!); // Update balance
    } catch (error) {
      console.error("Transaction failed:", error);
      alert("Transaction failed! See console for details.");
    }

    setLoading(false);
  }

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-900 text-white">
      <h1 className="text-4xl font-bold mb-4">Rock Paper Scissors (Web3)</h1>

      {account ? (
        <p>Connected: {account}</p>
      ) : (
        <button
          onClick={connectWallet}
          className="bg-blue-500 px-4 py-2 rounded"
        >
          Connect Wallet
        </button>
      )}

      <p className="mt-4">Contract Balance: {contractBalance} ETH</p>

      <input
        type="number"
        value={betAmount}
        onChange={(e) => setBetAmount(parseFloat(e.target.value))}
        className="mt-4 px-4 py-2 rounded text-black placeholder:text-gray-500"
        placeholder="Bet Amount (ETH)"
        step={0.001}
      />

      <div className="flex space-x-4 mt-6">
        {moves.map((move, index) => (
          <button
            key={index}
            onClick={() => playGame(index)}
            disabled={loading}
            className="bg-green-500 px-6 py-3 rounded text-lg"
          >
            {move}
          </button>
        ))}
      </div>

      {loading && <p className="mt-4">Waiting for transaction...</p>}

      {playerMove && (
        <div className="mt-6 text-lg">
          <p>
            <strong>You:</strong> {playerMove}
          </p>
          <p>
            <strong>Computer:</strong> {computerMove || "Waiting..."}
          </p>
          <p>
            <strong>Result:</strong> {result || "Pending..."}
          </p>
        </div>
      )}
    </div>
  );
}
