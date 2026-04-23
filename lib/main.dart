import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'constants.dart';
import 'game_engine.dart';
import 'components/zombie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  final game = DefenderGame();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(game: game),
            SafeArea(child: GameOverlay(game: game)),
          ],
        ),
      ),
    ),
  );
}

class GameOverlay extends StatelessWidget {
  final DefenderGame game;
  const GameOverlay({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: game.updateUI,
      builder: (context, _, __) {
        if (game.playerHP <= 0) {
          return const Center(
            child: Text("GAME OVER", style: TextStyle(fontSize: 60, color: Colors.red, fontWeight: FontWeight.bold))
          );
        }

        return Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: _glassBox("Health: ${game.playerHP}/20 | House: ${game.houseHP}/100 | Kills: ${game.kills}", width: 400),
            ),
            
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _glassBox("🪙 ${game.coins} Coins", isButton: false),
                    _glassBox("🔫 ${game.bullets} Ammo\n(Buy 12 for 10)", onTap: () {
                      if (game.coins >= GameConfig.bulletPackPrice) { 
                        game.coins -= GameConfig.bulletPackPrice; 
                        game.bullets += GameConfig.bulletPackAmount; 
                      }
                    }),
                    _glassBox("🧱 ${game.bricks} Bricks\n(Buy 1 for 2)", onTap: () {
                      if (game.coins >= GameConfig.brickPrice) { 
                        game.coins -= GameConfig.brickPrice; 
                        game.bricks++; 
                      }
                    }),
                    _glassBox("🚧 ${game.barriers} Barriers\n(Buy 1 for 3)", onTap: () {
                      if (game.coins >= GameConfig.barrierPrice) { 
                        game.coins -= GameConfig.barrierPrice; 
                        game.barriers++; 
                      }
                    }),
                  ],
                ),
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dPadButton(Icons.arrow_upward, () { if(game.player.gridY > 0) game.player.gridY--; }),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _dPadButton(Icons.arrow_back, () { if(game.player.gridX > (game.houseHP >= 100 ? 0 : 1)) game.player.gridX--; }),
                        const SizedBox(width: 50),
                        _dPadButton(Icons.arrow_forward, () { if(game.player.gridX < GameConfig.cols - 1) game.player.gridX++; }),
                      ],
                    ),
                    _dPadButton(Icons.arrow_downward, () { if(game.player.gridY < GameConfig.rows - 1) game.player.gridY++; }),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => game.player.fire(),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.8), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                        child: const Text("FIRE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Testing Spawn Buttons
            Align(
              alignment: Alignment.centerLeft, 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: const Icon(Icons.bug_report, color: Colors.green), onPressed: () => game.add(ZombieComponent('normie'))),
                  IconButton(icon: const Icon(Icons.bug_report, color: Colors.yellow), onPressed: () => game.add(ZombieComponent('upper_normie'))),
                  IconButton(icon: const Icon(Icons.bug_report, color: Colors.orange), onPressed: () => game.add(ZombieComponent('greater_normie'))),
                  IconButton(icon: const Icon(Icons.bug_report, color: Colors.red), onPressed: () => game.add(ZombieComponent('mommy'))),
                  IconButton(icon: const Icon(Icons.bug_report, color: Colors.purple), onPressed: () => game.add(ZombieComponent('super_mommy'))),
                ],
              )
            )
          ],
        );
      },
    );
  }

  Widget _glassBox(String text, {double? width, VoidCallback? onTap, bool isButton = true}) {
    Widget box = ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
    return isButton ? GestureDetector(onTap: onTap, child: Padding(padding: const EdgeInsets.all(8), child: box)) : Padding(padding: const EdgeInsets.all(8), child: box);
  }

  Widget _dPadButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.5), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}