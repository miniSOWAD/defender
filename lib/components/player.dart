import 'package:flame/components.dart';
import '../game_engine.dart';
import 'zombie.dart';
import 'bullet.dart';
import '../constants.dart';

class PlayerComponent extends SpriteComponent with HasGameRef<DefenderGame> {
  int gridX = 1, gridY = 3;
  
  PlayerComponent() : super(size: Vector2(64, 64), anchor: Anchor.center, priority: 3);

  @override
  Future<void> onLoad() async { 
    sprite = await gameRef.loadSprite('player.png'); 
  }

  @override
  void update(double dt) {
    if (gridX == 0 && gameRef.houseHP < 100) gridX = 1; 
    
    Vector2 targetPos = Vector2((gridX + 0.5) * gameRef.blockWidth, (gridY + 0.5) * gameRef.blockHeight);
    position.lerp(targetPos, 0.2);
  }

  void fire() {
    if (gameRef.bullets <= 0) return;
    gameRef.bullets--;
    
    ZombieComponent? closest;
    double minDistance = double.infinity;
    for (final zombie in gameRef.children.whereType<ZombieComponent>()) {
      double dist = zombie.position.distanceTo(position);
      if (dist < minDistance) { 
        minDistance = dist; 
        closest = zombie; 
      }
    }
    
    Vector2 direction = closest != null ? (closest.position - position).normalized() : Vector2(1, 0);
    
    double dmg = 1.0;
    if (gridX == 0 && closest != null) {
      dmg = GameConfig.zombieStats[closest.type]!['buffDmg'] as double;
    }
    
    gameRef.add(BulletComponent(pos: position.clone(), direction: direction, damage: dmg));
  }
}