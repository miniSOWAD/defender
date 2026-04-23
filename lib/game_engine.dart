import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'constants.dart';
import 'components/player.dart';
import 'components/house.dart';
import 'components/barrier.dart';

class DefenderGame extends FlameGame with TapCallbacks {
  int coins = 10, bullets = 24, bricks = 10, barriers = 5;
  double playerHP = 20.0, houseHP = 0.0;
  int kills = 0;

  double get blockWidth => size.x / GameConfig.cols;
  double get blockHeight => size.y / GameConfig.rows;

  late Sprite houseSprite, brokenSprite;
  late PlayerComponent player;

  final ValueNotifier<int> updateUI = ValueNotifier(0);

  @override
  Future<void> onLoad() async {
    houseSprite = await loadSprite('house.png');
    brokenSprite = await loadSprite('broken.png');

    // Garden Background (Priority -10 ensures it is always behind everything)
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
    }
    updateUI.value++;
  }

  @override
  void onTapDown(TapDownEvent event) {
    int tapCol = (event.canvasPosition.x / blockWidth).floor();
    int tapRow = (event.canvasPosition.y / blockHeight).floor();

    // Repair House
    if (tapCol == 0 && bricks > 0 && houseHP < 100) {
      bricks--; 
      houseHP = (houseHP + 3).clamp(0, 100);
    } 
    // Build Barrier
    else if (tapCol > 0 && barriers > 0) {
      bool isOccupied = children.whereType<BarrierComponent>().any((b) => b.gridX == tapCol && b.gridY == tapRow);
      if (!isOccupied) {
        barriers--;
        add(BarrierComponent(tapCol, tapRow));
      }
    }
  }

  void takePlayerDamage(double dmg) { 
    playerHP -= dmg; 
  }
}