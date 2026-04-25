import 'package:flame/components.dart';
import '../game_engine.dart';

class HouseComponent extends SpriteComponent with HasGameRef<DefenderGame> {
  HouseComponent() : super(priority: 0);

  @override
  Future<void> onLoad() async {
    sprite = gameRef.brokenSprite;
    // Keep fixed aspect ratio to prevent stretching
    double hWidth = gameRef.leftBezel * 0.8;
    double hHeight = gameRef.gridHeight * 0.6; 
    size = Vector2(hWidth, hHeight);
    
    // Positioned above the fire button in the left bezel
    position = Vector2(gameRef.leftBezel * 0.1, gameRef.topBezel + (gameRef.gridHeight - hHeight) / 2 - 20);
  }

  @override
  void update(double dt) {
    // State change visual
    sprite = gameRef.isHouseBuilt ? gameRef.houseSprite : gameRef.brokenSprite;
  }
}