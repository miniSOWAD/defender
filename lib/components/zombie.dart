import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../main.dart';
import '../constants.dart';

class ZombieComponent extends SpriteComponent with HasGameRef<ZombieSurvivalGame> {
  final String type;
  late double health;
  late int reward;
  final double speed = 40.0;

  ZombieComponent(this.type) : super(size: Vector2(80, 80));

  @override
  Future<void> onLoad() async {
    final stats = GameConfig.zombieStats[type]!;
    sprite = await gameRef.loadSprite(stats['sprite'] as String);
    health = stats['hp'] as double;
    reward = stats['coins'] as int;
    
    add(RectangleHitbox());
    
    // Spawn randomly on the right side of the screen
    double randomY = 100.0 + (gameRef.size.y - 200.0) * (gameRef.timer % 1); // Simple pseudo-random Y
    position = Vector2(gameRef.size.x + 50, randomY);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt; // Move left towards the house

    // Game Over condition if zombie reaches the house edge (x = 0)
    if (position.x < 0) {
      removeFromParent();
      // You can add Game Over logic here later
    }
  }

  void takeDamage(double amount) {
    health -= amount;
    if (health <= 0.01) { // 0.01 handles floating point precision issues
      gameRef.coins += reward;
      removeFromParent();
    }
  }
}