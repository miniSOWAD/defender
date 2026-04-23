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
    position = Vector2(gameRef.size.x + 40, (startY + 0.5) * gameRef.blockHeight);
  }

  @override
  void update(double dt) {
    int currentGridX = (position.x / gameRef.blockWidth).floor();
    int currentGridY = (position.y / gameRef.blockHeight).floor();
    
    BarrierComponent? barrier;
    for (final b in gameRef.children.whereType<BarrierComponent>()) {
      if (b.gridX == currentGridX && b.gridY == currentGridY) barrier = b;
    }

    if (barrier != null) {
      _attack(dt, () => barrier!.takeDamage(attackDmg));
    } else if (currentGridX <= gameRef.player.gridX) {
      if (position.distanceTo(gameRef.player.position) < 50) {
        _attack(dt, () => gameRef.takePlayerDamage(attackDmg));
      } else {
        Vector2 direction = (gameRef.player.position - position).normalized();
        position += direction * speed * dt;
      }
    } else {
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