import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'constants.dart';
import 'game_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: GameScreen()));
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final DefenderGame game = DefenderGame();
  DateTime lastMove = DateTime.now();
  final ValueNotifier<Offset> joystickOffset = ValueNotifier(Offset.zero);

  void _handleJoystickUpdate(DragUpdateDetails details) {
    double dx = details.localPosition.dx - 75; 
    double dy = details.localPosition.dy - 75;
    
    double distance = sqrt(dx * dx + dy * dy);
    if (distance > 50) {
      joystickOffset.value = Offset((dx / distance) * 50, (dy / distance) * 50);
    } else {
      joystickOffset.value = Offset(dx, dy);
    }

    if (DateTime.now().difference(lastMove).inMilliseconds < 200) return;
    if (distance < 20) return; 

    if (dx.abs() > dy.abs()) {
      if (dx > 0 && game.player.gridX < GameConfig.cols - 1) {
        game.player.gridX++; lastMove = DateTime.now();
      } 
      else if (dx < 0) {
        if (game.player.gridX > 0) {
          game.player.gridX--; lastMove = DateTime.now();
        } else if (game.player.gridX == 0 && game.isHouseBuilt) {
          if (game.player.gridY == 2 || game.player.gridY == 3) {
            game.player.gridX--; lastMove = DateTime.now();
          }
        }
      }
    } else {
      if (dy > 0) {
        if (game.player.gridX == -1 && game.player.gridY >= 3) return;
        if (game.player.gridY < GameConfig.rows - 1) {
          game.player.gridY++; lastMove = DateTime.now();
        }
      } else if (dy < 0) {
        if (game.player.gridX == -1 && game.player.gridY <= 2) return;
        if (game.player.gridY > 0) {
          game.player.gridY--; lastMove = DateTime.now();
        }
      }
    }
  }

  void _handleJoystickEnd(DragEndDetails details) {
    joystickOffset.value = Offset.zero; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),
          
          ValueListenableBuilder(
            valueListenable: game.updateUI,
            builder: (context, _, __) {
              if (game.playerHP <= 0) return const Center(child: Text("GAME OVER", style: TextStyle(fontSize: 60, color: Colors.red, fontWeight: FontWeight.bold)));

              return Stack(
                children: [
                  // --- TOP BEZEL (Info Bar) ---
                  Positioned(
                    top: 5, left: 130, right: 0, 
                    child: Center(
                      child: Column(
                        children: [
                          _glassBox("Health: ${game.playerHP.toStringAsFixed(1)}/20 | House: ${game.houseHP.toStringAsFixed(0)}/100 | Kills: ${game.kills} | ${game.isNight ? '🌙 NIGHT' : '☀️ DAY'}"),
                          
                          // --- THE FEAR BAR (Only displays at night) ---
                          if (game.isNight)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: _fearBar(game.fearLevel),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  // --- BOTTOM BEZEL (Shop Row) ---
                  Positioned(
                    bottom: 5, left: 130, right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(child: _glassBox("🪙 ${game.coins} Coins", isButton: false)),
                        Expanded(child: _glassBox("🔫 ${game.bullets} Ammo\n(Buy 12 : 10¢)", onTap: () { if (game.coins >= GameConfig.bulletPackPrice) { game.coins -= GameConfig.bulletPackPrice; game.bullets += GameConfig.bulletPackAmount; } })),
                        Expanded(child: _glassBox("🧱 ${game.bricks} Bricks\n(Buy 1 : 2¢)", onTap: () { if (game.coins >= GameConfig.brickPrice) { game.coins -= GameConfig.brickPrice; game.bricks++; } })),
                        Expanded(child: _glassBox("🚧 ${game.barriers} Barrier\n(Buy 1 : 3¢)", onTap: () { if (game.coins >= GameConfig.barrierPrice) { game.coins -= GameConfig.barrierPrice; game.barriers++; } })),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          
          // --- LEFT BEZEL (Fire Button) ---
          Positioned(
            bottom: 15, left: 20,
            child: GestureDetector(
              onTap: () => game.player.fire(),
              child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.8), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                child: const Center(child: Text("FIRE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))),
              ),
            ),
          ),

          // --- RIGHT SIDE (Joystick) ---
          Positioned(
            bottom: 80, right: 30,
            child: GestureDetector(
              onPanUpdate: _handleJoystickUpdate,
              onPanEnd: _handleJoystickEnd,
              child: Container(
                width: 150, height: 150,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.2))),
                child: Center(
                  child: ValueListenableBuilder<Offset>(
                    valueListenable: joystickOffset,
                    builder: (context, offset, child) {
                      return Transform.translate(
                        offset: offset,
                        child: Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle)),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassBox(String text, {VoidCallback? onTap, bool isButton = true}) {
    Widget box = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withOpacity(0.3))),
          child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ),
    );
    return isButton ? GestureDetector(onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: box)) : Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: box);
  }

  // --- THE 6-BLOCK FEAR UI WIDGET ---
  Widget _fearBar(double fearLevel) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.red.withOpacity(0.8), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(6, (index) {
          // Calculate how "full" this specific block should be (0.0 to 1.0)
          double fillAmount = (fearLevel - index).clamp(0.0, 1.0);
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              // Fills up red smoothly depending on the exact fear fraction
              color: Colors.red.withOpacity(fillAmount),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
          );
        }),
      ),
    );
  }
}