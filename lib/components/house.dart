import 'package:flame/components.dart';
import '../main.dart';

class HouseComponent extends SpriteComponent with HasGameRef<ZombieSurvivalGame> {
  HouseComponent() : super(size: Vector2(200, 300), position: Vector2(0, 100));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('broken.png');
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Dynamically change sprite when fully repaired
    if (gameRef.houseHP >= 100 && sprite != gameRef.houseSprite) {
      sprite = gameRef.houseSprite;
    } else if (gameRef.houseHP < 100 && sprite != gameRef.brokenSprite) {
      sprite = gameRef.brokenSprite;
    }
  }
}