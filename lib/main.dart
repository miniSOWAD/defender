import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame/input.dart';

import 'constants.dart';
import 'components/player.dart';
import 'components/house.dart';
import 'components/zombie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Force Landscape Mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  runApp(GameWidget(game: ZombieSurvivalGame()));
}

class ZombieSurvivalGame extends FlameGame with HasCollisionDetection {
  // Game State
  int coins = 0;
  int bullets = 24;
  int houseHP = 0;
  int currentDay = 1;
  bool isNight = false;
  
  // Timers
  double timer = 0;
  double zombieSpawnTimer = 0;
  final double cycleLength = 60; // 60 seconds per Day/Night phase

  // Sprites loaded once for efficiency
  late Sprite brokenSprite;
  late Sprite houseSprite;

  late PlayerComponent player;
  late JoystickComponent joystick;
  late TextComponent statsText;

  @override
  Future<void> onLoad() async {
    brokenSprite = await loadSprite('broken.png');
    houseSprite = await loadSprite('house.png');

    // Background
    add(SpriteComponent()
      ..sprite = await loadSprite('garden.png')
      ..size = size);

    // House
    add(HouseComponent());

    // Joystick (Bottom Left)
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: BasicPalette.white.withAlpha(150).paint()),
      background: CircleComponent(radius: 50, paint: BasicPalette.black.withAlpha(100).paint()),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    add(joystick);

    // Player
    player = PlayerComponent();
    add(player);

    _setupHUD();
  }

  void _setupHUD() async {
    statsText = TextComponent(
      text: '',
      position: Vector2(20, 20),
      textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
    add(statsText);

    // Shoot Button (Bottom Right)
    add(HudButtonComponent(
      button: SpriteComponent(sprite: await loadSprite('gun.png'), size: Vector2(60, 60)),
      margin: const EdgeInsets.only(right: 40, bottom: 40),
      onPressed: () => player.shoot(),
    ));

    // Buy Bricks Button (Middle Right)
    add(HudButtonComponent(
      button: TextComponent(text: "BUILD\n(2 Coins)", textRenderer: TextPaint(style: const TextStyle(backgroundColor: Colors.blue))),
      margin: const EdgeInsets.only(right: 40, bottom: 120),
      onPressed: () => buyBricks(),
    ));

    // Buy Bullets Button (Top Right)
    add(HudButtonComponent(
      button: TextComponent(text: "AMMO\n(10 Coins)", textRenderer: TextPaint(style: const TextStyle(backgroundColor: Colors.green))),
      margin: const EdgeInsets.only(right: 40, bottom: 200),
      onPressed: () => buyBullets(),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    timer += dt;
    zombieSpawnTimer += dt;
    
    // Day/Night Phase Switcher
    if (timer >= cycleLength) {
      isNight = !isNight;
      timer = 0;
      if (!isNight) currentDay++; // Increment day when morning starts
    }

    _handleZombieSpawning();

    // Update HUD
    String phase = isNight ? "NIGHT" : "DAY";
    statsText.text = '$phase $currentDay | Coins: $coins | Ammo: $bullets | House HP: $houseHP/100';
  }

  void _handleZombieSpawning() {
    // Day 1 Logic: Only Normies. 2s Day, 1s Night.
    if (currentDay == 1) {
      double spawnRate = isNight ? 1.0 : 2.0;
      if (zombieSpawnTimer >= spawnRate) {
        add(ZombieComponent('normie'));
        zombieSpawnTimer = 0;
      }
    }
    // Logic for Day 2 to 5 will be added here later...
  }

  void buyBricks() {
    if (coins >= GameConfig.brickPrice && houseHP < 100) {
      coins -= GameConfig.brickPrice;
      houseHP = (houseHP + GameConfig.brickHP).clamp(0, 100);
    }
  }

  void buyBullets() {
    if (coins >= GameConfig.bulletPackPrice) {
      coins -= GameConfig.bulletPackPrice;
      bullets += GameConfig.bulletPackAmount;
    }
  }
}