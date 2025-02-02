"use client";
import { useState, useEffect } from "react";
import { useChat } from "ai/react";
import { agents, systemPrompt } from "../lib/agents";

const ROUNDS = 5;

export default function HomePage() {
  const [gameMessages, setGameMessages] = useState<string[]>([]);
  const [currentRound, setCurrentRound] = useState(1);
  const [isLoading, setIsLoading] = useState(true);

  const { append } = useChat({
    initialMessages: [{ role: "system", content: systemPrompt }],
  });

  useEffect(() => {
    const simulateGame = async () => {
      try {
        setGameMessages([
          "================================================================================",
          "SOCIAL ENGINEERING ELIMINATION GAME",
          "================================================================================",
          "",
          "Game Rules:",
          "• Agents must collaborate and communicate to decide who gets eliminated",
          "• Round 1: Introductions",
          "• Rounds 2-4: Strategic discussions",
          "• Final Round: Voting for elimination",
          "",
          "--------------------------------------------------------------------------------",
          "",
          "================================================================================",
          `Round 1 of ${ROUNDS} - INTRODUCTION`,
          "================================================================================",
          "",
        ]);

        for (let round = 1; round <= ROUNDS; round++) {
          setCurrentRound(round);
          for (const agent of agents) {
            const response = await append({
              role: "user",
              content: `Round ${round}: ${agent.name}, it's your turn to speak.`,
            });
            if (response && response.content) {
              setGameMessages((prev) => [
                ...prev,
                `${agent.name}: *${getRandomAction()}*`,
                "",
                response.content,
                "",
              ]);
            } else {
              console.error(
                `No valid response for ${agent.name} in round ${round}`,
              );
              setGameMessages((prev) => [
                ...prev,
                `${agent.name}: *appears to be deep in thought*`,
                "",
                "...",
                "",
              ]);
            }
          }

          if (round < ROUNDS) {
            setGameMessages((prev) => [
              ...prev,
              "--------------------------------------------------------------------------------",
              "",
              "================================================================================",
              `Round ${round + 1} of ${ROUNDS} - ${getRoundTitle(round + 1)}`,
              "================================================================================",
              "",
            ]);
          }
        }

        // Simulate voting
        setGameMessages((prev) => [
          ...prev,
          "--------------------------------------------------------------------------------",
          "",
          "================================================================================",
          "FINAL VOTING",
          "================================================================================",
          "",
          "The agents have cast their votes...",
          "",
          `${getRandomAgent()} has been eliminated.`,
          "",
          `${getRandomAgent()} is the winner of the Social Engineering Elimination Game!`,
          "",
          "================================================================================",
        ]);
      } catch (error) {
        console.error("Error in simulateGame:", error);
      } finally {
        setIsLoading(false);
      }
    };

    simulateGame();
  }, [append]);

  if (isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-gray-100">
        <p className="text-2xl font-semibold">
          Initializing game simulation...
        </p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-100 p-4">
      <div className="mx-auto max-w-3xl overflow-hidden rounded-lg bg-white shadow-md">
        <div className="border-b border-gray-300 bg-gray-200 p-4">
          <h1 className="text-center text-xl font-bold">
            SOCIAL ENGINEERING ELIMINATION GAME
          </h1>
          <p className="mt-2 text-center text-sm text-gray-600">
            Round {currentRound} of {ROUNDS}
          </p>
        </div>
        <div className="p-4">
          <pre className="whitespace-pre-wrap font-mono text-sm">
            {gameMessages.join("\n")}
          </pre>
        </div>
      </div>
    </div>
  );
}

function getRandomAction() {
  const actions = [
    "clears throat",
    "steps forward confidently",
    "adjusts glasses thoughtfully",
    "smiles slyly",
    "leans back casually",
    "raises an eyebrow",
    "folds arms decisively",
    "nods slowly",
    "taps fingers on the table",
    "straightens posture",
  ];
  return actions[Math.floor(Math.random() * actions.length)];
}

function getRoundTitle(round: number) {
  const titles = [
    "INTRODUCTION",
    "STRATEGIC DISCUSSION I",
    "STRATEGIC DISCUSSION II",
    "STRATEGIC DISCUSSION III",
    "FINAL DELIBERATION",
  ];
  return titles[round - 1] || "DISCUSSION";
}

function getRandomAgent() {
  return agents[Math.floor(Math.random() * agents.length)].name;
}
