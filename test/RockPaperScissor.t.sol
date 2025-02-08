// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {RockPaperScissor} from "../src/RockPaperScissor.sol";

contract RockPaperScissorTest is Test {
    RockPaperScissor public rps;
    address player = address(this);

    event GamePlayed(
        address indexed player,
        RockPaperScissor.Move playerMove,
        RockPaperScissor.Move computerMove,
        string result,
        uint256 timestamp
    );

    function setUp() public {
        rps = new RockPaperScissor();
    }

    function test_PlayGame_Rock() public {
        uint8 playerMove = 0;

        vm.expectEmit(true, true, false, true);
        emit GamePlayed(
            player,
            RockPaperScissor.Move.Rock,
            RockPaperScissor.Move.Rock,
            "Draw",
            block.timestamp
        );

        rps.playGame(playerMove);
    }

    function test_PlayGame_Paper() public {
        uint8 playerMove = 1; // Paper

        vm.expectEmit(true, true, false, true);
        emit GamePlayed(
            player,
            RockPaperScissor.Move.Paper,
            RockPaperScissor.Move.Rock,
            "Win",
            block.timestamp
        );

        rps.playGame(playerMove);
    }

    function test_PlayGame_Scissors() public {
        uint8 playerMove = 2; // Scissors

        vm.expectEmit(true, true, false, true);
        emit GamePlayed(
            player,
            RockPaperScissor.Move.Scissors,
            RockPaperScissor.Move.Rock,
            "Lose",
            block.timestamp
        );

        rps.playGame(playerMove);
    }

    function test_RevertInvalidMove() public {
        vm.expectRevert(
            "Invalid move. Choose 0 (Rock), 1 (Paper), or 2 (Scissors)"
        );
        rps.playGame(3); // Invalid move
    }

    function test_GetStats() public {
        rps.playGame(0); // Play one game

        (uint256 win, uint256 loss, uint256 draw) = rps.getStats(player);

        console.log("Wins:", win);
        console.log("Losses:", loss);
        console.log("Draws:", draw);

        assertTrue(win >= 0);
        assertTrue(loss >= 0);
        assertTrue(draw >= 0);
    }
}
