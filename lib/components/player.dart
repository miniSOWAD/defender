import 'dart:ui'; // Required for the Canvas rendering
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
    // Evict out to the lawn (0) ONLY if the house is destroyed
    if (gridX == -1 && !gameRef.isHouseBuilt) gridX = 0; 
    
    Vector2 targetPos;
    if (gridX == -1) {
      // Player is mathematically inside the left bezel
      targetPos = Vector2(gameRef.leftBezel * 0.5, gameRef.topBezel + (gridY + 0.5) * gameRef.blockHeight);
    } else {
      // Player is anywhere on the 15-column lawn
      targetPos = Vector2(gameRef.leftBezel + (gridX + 0.5) * gameRef.blockWidth, gameRef.topBezel + (gridY + 0.5) * gameRef.blockHeight);
    }
    
    position.lerp(targetPos, 0.2);
  }

  // --- NEW: HIDE PLAYER WHEN INSIDE THE HOUSE ---
  @override
  void render(Canvas canvas) {
    // Only draw the player's sprite if they are NOT in column -1
    if (gridX != -1) {
      super.render(canvas);
    }
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
    // Firing from the bezel (-1) gives the buff
    if (gridX == -1 && closest != null) {
      dmg = GameConfig.zombieStats[closest.type]!['buffDmg'] as double;
    }
    
    gameRef.add(BulletComponent(pos: position.clone(), direction: direction, damage: dmg));
  }
}