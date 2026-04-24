import 'package:flame/components.dart';
import '../game_engine.dart';

class HouseComponent extends SpriteComponent with HasGameRef<DefenderGame> {
  HouseComponent() : super(priority: 0);

  @override
  Future<void> onLoad() async {
    sprite = gameRef.brokenSprite;
    // Do not stretch fully vertically. Keep it looking good in the left bezel.
    double hWidth = gameRef.leftBezel * 0.8;
    double hHeight = gameRef.gridHeight * 0.6; 
    size = Vector2(hWidth, hHeight);
    
    // Center it in the left bezel, slightly above the bottom fire button
    position = Vector2(gameRef.leftBezel * 0.1, gameRef.topBezel + (gameRef.gridHeight - hHeight) / 2 - 20);
  }

  @override
  void update(double dt) {
    sprite = gameRef.isHouseBuilt ? gameRef.houseSprite : gameRef.brokenSprite;
  }
}