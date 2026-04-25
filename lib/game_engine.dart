import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart'; // for ValueNotifier
import 'constants.dart';
import 'components/player.dart';
import 'components/house.dart';
import 'components/barrier.dart';

// --- MAIN GAME STATES ---
enum GameState { mainMenu, playing, paused, gameOver }

class DefenderGame extends FlameGame with TapCallbacks {
  int coins = 10, bullets = 24, bricks = 10, barriers = 5;
  double playerHP = 20.0, houseHP = 0.0;
  int kills = 0;
  bool isHouseBuilt = false; 

  // --- DAY/NIGHT & FEAR VARIABLES ---
  bool isNight = false;
  double cycleTimer = 0.0; 
  double fearLevel = 0.0;  // 0.0 to 6.0
  double zombieSpawnTimer = 0.0;

  // --- MENU STATES ---
  GameState _state = GameState.playing; // Start in playing state for this part
  GameState get state => _state;

  // Bezel Layout System
  double get topBezel => 50.0;
  double get bottomBezel => 80.0;
  double get leftBezel => 130.0; 
  
  double get gridWidth => size.x - leftBezel; 
  double get gridHeight => size.y - topBezel - bottomBezel;

  double get blockWidth => gridWidth / GameConfig.cols;
  double get blockHeight => gridHeight / GameConfig.rows;

  late Sprite houseSprite, brokenSprite, daySprite, nightSprite;
  late SpriteComponent background;
  late PlayerComponent player;
  final ValueNotifier<int> updateUI = ValueNotifier(0);

  @override
  Future<void> onLoad() async {
    houseSprite = await loadSprite('house.png');
    brokenSprite = await loadSprite('broken.png');
    daySprite = await loadSprite('garden.png');
    nightSprite = await loadSprite('night.png'); 

    // Initialize background with Day sprite
    background = SpriteComponent()
      ..sprite = daySprite
      ..size = size
      ..priority = -10;
    add(background);

    add(HouseComponent());
    player = PlayerComponent();
    add(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_state != GameState.playing) return; // Freeze logic if paused or not playing

    if (playerHP <= 0) {
      _state = GameState.gameOver;
      return;
    }

    // --- DAY / NIGHT CYCLE LOGIC (120 secs each) ---
    cycleTimer += dt;
    if (cycleTimer >= 120.0) { 
      cycleTimer = 0.0;
      isNight = !isNight;
      background.sprite = isNight ? nightSprite : daySprite;
      if (!isNight) fearLevel = 0.0; // Reset fear when morning comes
    }

    // --- FEAR MECHANIC ---
    if (isNight) {
      if (player.gridX >= 0) {
        // Player is outside: Fill 1 block every 2 seconds (6 blocks in 12 secs)
        fearLevel += dt / 2.0;
      } else if (player.gridX == -1) {
        // Player is inside: Empty 1 block every 4 seconds (6 blocks in 24 secs)
        fearLevel -= dt / 4.0;
      }
      
      fearLevel = fearLevel.clamp(0.0, 6.0); 

      // If fully terrified (6 blocks maxed), lose 0.5 HP per second
      if (fearLevel >= 6.0) {
        takePlayerDamage(0.5 * dt);
      }
    }

    // --- ZOMBIE SPAWNER ---
    zombieSpawnTimer += dt;
    double currentSpawnRate = isNight ? 2.0 : 3.0; // 2 secs at night, 3 secs at day
    
    if (zombieSpawnTimer >= currentSpawnRate) {
      zombieSpawnTimer = 0.0;
      //... logic for random zombie type spawn
    }

    updateUI.value++;
  }

  @override
  void onTapDown(TapDownEvent event) {
    double tapX = event.canvasPosition.x;
    double tapY = event.canvasPosition.y;

    if (tapX < leftBezel) {
      if (bricks > 0 && houseHP < 100) {
        bricks--; 
        houseHP = (houseHP + 3).clamp(0, 100);
        if (houseHP >= 100) isHouseBuilt = true; 
      }
    } else {
      //... logic for barrier placement on 6x15 grid
    }
  }

  void takePlayerDamage(double dmg) { playerHP -= dmg; }

  // --- GAME STATE COMMANDS ---
  void pause() {
    if (_state == GameState.playing) {
      _state = GameState.paused;
      updateUI.value++;
    }
  }

  void resume() {
    if (_state == GameState.paused) {
      _state = GameState.playing;
      updateUI.value++;
    }
  }

  void exitToMainMenu() {
    _state = GameState.mainMenu;
    updateUI.value++;
  }

  void startNewGame() {
    //... logic to reset all variables
    _state = GameState.playing;
    updateUI.value++;
  }
}