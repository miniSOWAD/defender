import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../main.dart';
import 'bullet.dart';

class PlayerComponent extends SpriteComponent with HasGameRef<ZombieSurvivalGame> {
  final double speed = 200.0;
  int facingDirection = 1; // 1 for right, -1 for left

  PlayerComponent() : super(size: Vector2(64, 64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('player.png');
    position = gameRef.size / 2;
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    final joystick = gameRef.joystick;
    if (!joystick.delta.isZero()) {
      position.add(joystick.relativeDelta * speed * dt);
      
      // Flip sprite based on movement direction
      if (joystick.relativeDelta.x < 0 && facingDirection == 1) {
        flipHorizontallyAroundCenter();
        facingDirection = -1;
      } else if (joystick.relativeDelta.x > 0 && facingDirection == -1) {
        flipHorizontallyAroundCenter();
        facingDirection = 1;
      }
    }
    
    // Clamp to screen bounds
    position.clamp(Vector2(32, 32), gameRef.size - Vector2(32, 32));
  }

  void shoot() {
    if (gameRef.bullets > 0) {
      gameRef.bullets--;
      
      // Check if player is inside the repaired house (x < 200 bounds)
      bool insideHouse = (gameRef.houseHP >= 100 && position.x < 200);
      
      gameRef.add(BulletComponent(
        position: position.clone(), 
        direction: facingDirection,
        isBuffed: insideHouse,
      ));
    }
  }
}