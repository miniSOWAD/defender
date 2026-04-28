# 🧟 DEFENDER

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:16a34a,50:b91c1c,100:000000&height=220&section=header&text=DEFENDER&fontSize=58&fontColor=ffffff&animation=fadeIn&fontAlignY=35&desc=2D%20Pixel%20Art%20Zombie%20Survival%20Built%20with%20Flutter%20and%20Flame&descAlignY=60"/>
</p>

<p align="center">
<img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter">
<img alt="Dart" src="https://img.shields.io/badge/Dart-3.x-blue?logo=dart">
<img alt="Flame Engine" src="https://img.shields.io/badge/Engine-Flame-orange">
<img alt="Platform" src="https://img.shields.io/badge/Platform-Web%20%7C%20Mobile-green">
<img alt="Game" src="https://img.shields.io/badge/Genre-2D%20Zombie%20Survival-red">
</p>

---

# 🚀 About The Project

**DEFENDER** is a relentless **2D zombie survival game** built using **Flutter** and the **Flame Game Engine**. 

You play as a lone survivor holding the line against endless waves of the undead. Your mission is simple: defend your position, manage your resources, and survive the night.

* 🔫 **Shoot** through hordes of incoming zombies.
* 🛡️ **Defend** your base and repair barricades.
* 📦 **Collect** ammo, health packs, and weapon upgrades.
* 🌊 **Survive** increasingly difficult waves of mutated enemies.

This project demonstrates **swarm AI pathfinding, projectile physics, wave-based state management, and particle effects** across mobile and web platforms.

---

# 🎮 Gameplay

The gameplay loop is built around crowd control and resource management:

1. Stand your ground and use the virtual joystick to aim and fire.
2. Eliminate zombies before they breach your defenses.
3. Manage your ammo count and reload strategically.
4. Pick up dropped loot (health, rapid-fire, spread shot) to turn the tide.
5. Survive the wave to face faster, stronger enemy types in the next round.

---

# ✨ Features

## 🤠 Player & Arsenal System

* 360-degree aiming and shooting mechanics.
* Ammo management and reload systems.
* Multiple weapon states (e.g., Pistol, Shotgun, Assault Rifle).
* Smooth, continuous movement clamped to the defense zone.

## 🧟 Swarm AI Behaviors

* **Walkers:** Slow, standard zombies that swarm in large numbers.
* **Runners:** Fast, low-health zombies that rush the player.
* **Tank Mutants:** High-health bullet sponges that deal massive damage.
* Pathfinding logic that continually tracks the player's position.

## 🌊 Dynamic Wave System

* Endless scaling difficulty.
* Enemies increase in speed, health, and spawn rate as waves progress.
* Intermission periods for reloading and planning.

## 📱 Custom HUD & Menus

* Native Flutter UI overlays for Main Menu, Pause, and Game Over screens.
* Real-time survival HUD tracking:
  * ❤️ Health & 🛡️ Barricade Integrity
  * 🔫 Ammo Counter
  * 🌊 Wave Number
  * 🏆 Score & Kill Count

---

# 🎮 Controls

## Desktop & Web

| Action | Control |
|--------|---------|
| Move | W A S D / Arrow Keys |
| Aim & Shoot | Mouse Cursor & Left Click |
| Pause | Top-Right Pause Button |

## Mobile

| Action | Control |
|--------|---------|
| Move | Left Virtual Joystick |
| Aim & Shoot | Right Virtual Joystick / Tap to Shoot |
| Pause | Top-Right Pause Button |

---

# 🧱 Tech Stack

| Technology | Role |
|------------|------|
| Flutter | Cross‑platform framework & Overlay UI |
| Flame Engine | 2D game engine loop & physics |
| Dart | Core programming language |
| Canvas Rendering | Sprite rendering and game visuals |

---

# 📂 Project Structure

```text
lib/
│
├── main.dart                 # App entry point, theme, and UI Overlays
├── defender_game.dart        # Core game loop, wave manager, state
├── constants.dart            # Global game settings (speeds, spawns, damage)
│
└── components/
    ├── survivor.dart         # Player logic, aiming, shooting
    ├── zombie.dart           # Enemy logic, AI tracking, collisions
    ├── bullet.dart           # Projectile mechanics and damage calculation
    ├── drop_item.dart        # Loot mechanics (Health, Ammo, Guns)
    ├── background.dart       # Environment rendering
    └── hud.dart              # Flame-based text and progress bars
