import 'package:flame/components.dart';
import '../game_engine.dart';

class HouseComponent extends SpriteComponent with HasGameRef<DefenderGame> {
  HouseComponent() : super(priority: 0);

  @override
  Future<void> onLoad() async {
    sprite = gameRef.brokenSprite;
    size = Vector2(gameRef.blockWidth, gameRef.size.y);
    position = Vector2.zero();
  }

  @override
  void update(double dt) {
    sprite = gameRef.houseHP >= 100 ? gameRef.houseSprite : gameRef.brokenSprite;
  }
}