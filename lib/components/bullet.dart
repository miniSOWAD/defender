import 'dart:math';
import 'package:flame/components.dart';
import '../game_engine.dart';
import 'zombie.dart';

class BulletComponent extends SpriteComponent with HasGameRef<DefenderGame> {
  final Vector2 direction;
  final double damage;
  final double speed = 600.0;

  BulletComponent({required Vector2 pos, required this.direction, required this.damage}) 
      : super(position: pos, size: Vector2(20, 10), anchor: Anchor.center, priority: 5);
  
  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('bullet.png');
    angle = atan2(direction.y, direction.x);
  }

  @override
  void update(double dt) {
    position += direction * speed * dt;
    
    if (position.x > gameRef.size.x || position.x < 0 || position.y > gameRef.size.y || position.y < 0) {
      removeFromParent();
      return;
    }

    for (final zombie in gameRef.children.whereType<ZombieComponent>()) {
      if (zombie.toRect().contains(position.toOffset())) {
        zombie.takeDamage(damage);
        removeFromParent();
        break;
      }
    }
  }
}