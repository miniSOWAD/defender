import 'dart:math';
import 'package:flame/components.dart';
import '../constants.dart';
import '../game_engine.dart';
import 'barrier.dart';

class ZombieComponent extends SpriteComponent with HasGameRef<DefenderGame> {
  final String type;
  late double hp, attackDmg;
  late int reward;
  double attackTimer = 0.0;
  final double speed = 30.0;

  ZombieComponent(this.type) : super(size: Vector2(80, 80), anchor: Anchor.center, priority: 2);

  @override
  Future<void> onLoad() async {
    final stats = GameConfig.zombieStats[type]!;
    sprite = await gameRef.loadSprite(stats['sprite'] as String);
    hp = stats['hp'] as double;
    reward = stats['coins'] as int;
    attackDmg = stats['dmg'] as double;
    
    int startY = Random().nextInt(GameConfig.rows);
    // Spawn off-screen to the right
    position = Vector2(gameRef.size.x + 40, gameRef.topBezel + (startY + 0.5) * gameRef.blockHeight);
  }

  @override
  void update(double dt) {
    int currentGridX = ((position.x - gameRef.leftBezel) / gameRef.blockWidth).floor();
    int currentGridY = ((position.y - gameRef.topBezel) / gameRef.blockHeight).floor();
    
    BarrierComponent? barrier;
    for (final b in gameRef.children.whereType<BarrierComponent>()) {
      if (b.gridX == currentGridX && b.gridY == currentGridY) barrier = b;
    }

    if (barrier != null) {
      // Stopped by a barrier! Attack it.
      _attack(dt, () => barrier!.takeDamage(attackDmg));
    } 
    // Condition: Zombie reached the player's column OR player is hiding inside the house (-1) and zombie reached col 0
    else if (currentGridX <= gameRef.player.gridX || (gameRef.player.gridX == -1 && currentGridX <= 0)) {
      
      // Calculate the exact Y-coordinate of the player's current row
      double targetY = gameRef.topBezel + (gameRef.player.gridY + 0.5) * gameRef.blockHeight;
      bool isVerticallyAligned = (position.y - targetY).abs() < 5.0; // Small pixel tolerance
      
      if (gameRef.player.gridX == -1 && gameRef.isHouseBuilt && currentGridX <= 0) {
        // --- PLAYER IS INSIDE THE HOUSE ---
        // 1. Move vertically until aligned with the player's row
        if (!isVerticallyAligned) {
           position.y += (targetY > position.y ? 1 : -1) * speed * dt;
        }
        
        // 2. Keep moving left until physically touching the house bezel
        if (position.x > gameRef.leftBezel) {
           position.x -= speed * dt;
        } else if (isVerticallyAligned) {
           // 3. Aligned with player AND touching the house. Start smashing!
           _attack(dt, () {
             gameRef.houseHP -= attackDmg;
             if (gameRef.houseHP <= 0) {
               gameRef.houseHP = 0;
               gameRef.isHouseBuilt = false; // House breaks, triggering eviction!
             }
           });
        }
      } else {
        // --- STANDARD CHASE (Player is outside, or house just broke) ---
        if (position.distanceTo(gameRef.player.position) < 50) {
          // Close enough to bite the player
          _attack(dt, () => gameRef.takePlayerDamage(attackDmg));
        } else {
          // Move directly towards the player
          Vector2 direction = (gameRef.player.position - position).normalized();
          position += direction * speed * dt;
        }
      }
    } else {
      // --- NORMAL MOVEMENT ---
      // Still on the lawn, move left
      position.x -= speed * dt;
    }
  }

  void _attack(double dt, void Function() onAttack) {
    attackTimer += dt;
    if (attackTimer >= 2.0) {
      onAttack();
      attackTimer = 0.0;
    }
  }

  void takeDamage(double amount) {
    hp -= amount;
    if (hp <= 0) {
      gameRef.coins += reward;
      gameRef.kills++;
      removeFromParent();
    }
  }
}