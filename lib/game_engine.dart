import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'components/player.dart';
import 'components/house.dart';
import 'components/barrier.dart';
import 'dart:math';
import 'components/zombie.dart';

class DefenderGame extends FlameGame with TapCallbacks {
  int coins = 10, bullets = 24, bricks = 10, barriers = 5;
  double spawnTimer = 0.0;
  double playerHP = 20.0, houseHP = 0.0;
  int kills = 0;
  bool isHouseBuilt = false;

  // --- BEZEL LAYOUT SYSTEM ---
  double get topBezel => 50.0;
  double get bottomBezel => 80.0;
  double get leftBezel => 130.0; // Space for house & fire button
  
  double get gridWidth => size.x - leftBezel; // No right bezel
  double get gridHeight => size.y - topBezel - bottomBezel;

  double get blockWidth => gridWidth / GameConfig.cols;
  double get blockHeight => gridHeight / GameConfig.rows;

  late Sprite houseSprite, brokenSprite;
  late PlayerComponent player;
  final ValueNotifier<int> updateUI = ValueNotifier(0);

  @override
  Future<void> onLoad() async {
    houseSprite = await loadSprite('house.png');
    brokenSprite = await loadSprite('broken.png');

    // Stretched background
    add(SpriteComponent()
      ..sprite = await loadSprite('garden.png')
      ..size = size
      ..priority = -10);

    add(HouseComponent());
    player = PlayerComponent();
    add(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (playerHP <= 0) {
      pauseEngine();
      return; // Stop updating if player is dead
    }

    // --- AUTOMATIC ZOMBIE SPAWNER ---
    spawnTimer += dt;
    if (spawnTimer >= 2.5) {
      spawnTimer = 0.0;
      
      // Pick a random zombie type
      List<String> types = ['normie', 'upper_normie', 'greater_normie', 'mommy', 'super_mommy'];
      String randomType = types[Random().nextInt(types.length)];
      
      add(ZombieComponent(randomType));
    }

    updateUI.value++;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Draw subtle grid lines to clearly show the 90 blocks over the background
    final paint = Paint()..color = Colors.white.withOpacity(0.15)..style = PaintingStyle.stroke..strokeWidth = 1;
    for (int i = 0; i <= GameConfig.cols; i++) {
      canvas.drawLine(Offset(leftBezel + i * blockWidth, topBezel), Offset(leftBezel + i * blockWidth, size.y - bottomBezel), paint);
    }
    for (int i = 0; i <= GameConfig.rows; i++) {
      canvas.drawLine(Offset(leftBezel, topBezel + i * blockHeight), Offset(size.x, topBezel + i * blockHeight), paint);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    double tapX = event.canvasPosition.x;
    double tapY = event.canvasPosition.y;

    if (tapX < leftBezel) {
      // Clicked in House Bezel
      if (bricks > 0 && houseHP < 100) {
        bricks--; 
        houseHP = (houseHP + 3).clamp(0, 100);
        if (houseHP >= 100) isHouseBuilt = true;
      }
    } else {
      // Clicked in Grid Area
      int tapCol = ((tapX - leftBezel) / blockWidth).floor();
      int tapRow = ((tapY - topBezel) / blockHeight).floor();
      
      if (tapCol >= 0 && tapCol < GameConfig.cols && tapRow >= 0 && tapRow < GameConfig.rows) {
        if (barriers > 0) {
          bool isOccupied = children.whereType<BarrierComponent>().any((b) => b.gridX == tapCol && b.gridY == tapRow);
          if (!isOccupied) {
            barriers--;
            add(BarrierComponent(tapCol, tapRow));
          }
        }
      }
    }
  }

  void takePlayerDamage(double dmg) { playerHP -= dmg; }
}