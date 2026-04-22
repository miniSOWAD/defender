import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'zombie.dart';
import '../main.dart';
import '../constants.dart';

class BulletComponent extends SpriteComponent with HasGameRef<ZombieSurvivalGame>, CollisionCallbacks {
  final int direction; // 1 for right, -1 for left
  final double speed = 500.0;
  final bool isBuffed; // Calculated when the bullet is fired

  BulletComponent({required Vector2 position, required this.direction, required this.isBuffed}) 
      : super(position: position, size: Vector2(20, 10), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('bullet.png');
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    position.x += direction * speed * dt;
    if (position.x > gameRef.size.x || position.x < 0) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is ZombieComponent) {
      double damage = 1.0; // Standard outside damage
      
      if (isBuffed) {
        // Apply the specific buffed damage from constants to hit your exact bullet counts
        damage = GameConfig.zombieStats[other.type]!['buffedDamage'] as double;
      }
      
      other.takeDamage(damage);
      removeFromParent(); // Destroy bullet
    }
  }
}