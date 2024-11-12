---

# PingPong Game in 8088 Assembly Language

This project implements a simple **PingPong** game in 8088 Assembly Language, simulating a two-player game with paddles and a bouncing ball on a black screen.

## Table of Contents
1. [Project Description](#project-description)
2. [Game Requirements](#game-requirements)
3. [Installation](#installation)
4. [Gameplay](#gameplay)
5. [Controls](#controls)
6. [Scoring and Termination](#scoring-and-termination)
7. [Contributors](#contributors)

---

## Project Description
This project is a part of the **Computer Organization & Assembly Language** course for BSE students. The goal is to develop a functional PingPong game where two players control paddles to bounce a ball within game boundaries. It incorporates screen clearing, timer-based ball movement, paddle control, scoring, and game termination.

## Game Requirements
1. **Initial Screen Setup**:
   - Clear the screen with a black background.
   - Set **Player A’s paddle** on the top row (Row 0) centered at Column 30, spanning 20 cells.
   - Set **Player B’s paddle** on the bottom row (Row 24) similarly positioned.
   - Place the ball (a white star `*`) at Row 23, Column 40.

2. **Ball Movement**:
   - The ball moves diagonally with each timer tick.
   - Bounces off paddles, screen edges, and changes direction accordingly.

3. **Player Turns**:
   - Alternate turns based on the ball’s movement direction.
   - When the ball reaches Player A’s side, Player B’s turn begins, and vice versa.

4. **Paddle Movement**:
   - Each player can move their paddle left or right within their turn.

5. **Scoring System**:
   - A player scores if the opponent misses the ball.
   - The game ends when one player reaches 5 points.

6. **Game Termination**:
   - Proper cleanup ensures other programs run smoothly after game termination.

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/COAL-PING-PONG.git
   ```
2. Run the game in an 8088-compatible environment like DOSBox or COAL.

## Gameplay
Each player uses paddle movements to prevent the ball from passing their row. As the ball bounces off walls and paddles, its direction reverses, requiring quick reactions.

## Controls
- **Player A**: Moves paddle left/right using designated keys (e.g., arrow keys).
- **Player B**: Moves paddle left/right similarly during their turn.

## Scoring and Termination
- A score is given when a player misses the ball.
- The game ends once a player scores 5 points, at which point the screen resets.

## Contributors
- Muhammad Ahmad Butt
- Abdurehman

**Institution**: FAST NUCES Lahore, Pakistan  
**Course**: Computer Organization & Assembly Language, Fall 2024

---
