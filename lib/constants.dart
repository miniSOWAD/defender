class GameConfig {
  static const int brickPrice = 2;
  static const int barrierPrice = 3;
  static const int bulletPackPrice = 10;
  static const int bulletPackAmount = 12;

  static const int cols = 15;
  static const int rows = 6;

  static const Map<String, Map<String, dynamic>> zombieStats = {
    'normie':         {'hp': 3.0,  'coins': 3,  'dmg': 1.0,  'buffDmg': 1.5,   'sprite': 'no.png'},
    'upper_normie':   {'hp': 5.0,  'coins': 5,  'dmg': 1.0,  'buffDmg': 1.25,  'sprite': 'uno.png'},
    'greater_normie': {'hp': 7.0,  'coins': 8,  'dmg': 1.33, 'buffDmg': 1.167, 'sprite': 'gno.png'},
    'mommy':          {'hp': 9.0,  'coins': 10, 'dmg': 2.0,  'buffDmg': 1.125, 'sprite': 'mo.png'},
    'super_mommy':    {'hp': 12.0, 'coins': 15, 'dmg': 4.0,  'buffDmg': 1.2,   'sprite': 'smo.png'},
  };
}