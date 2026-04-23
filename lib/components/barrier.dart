import 'package:flame/components.dart';
import '../game_engine.dart';

class BarrierComponent extends SpriteComponent with HasGameRef<DefenderGame> {
  int gridX, gridY;
  double hp = 4.0;
  
  BarrierComponent(this.gridX, this.gridY) : super(priority: 1);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('barrier.png');
    size = Vector2(gameRef.blockWidth, gameRef.blockHeight);
    position = Vector2(gridX * gameRef.blockWidth, gridY * gameRef.blockHeight);
  }

  void takeDamage(double amount) {
    hp -= amount;
    if (hp <= 0) removeFromParent();
  }
}