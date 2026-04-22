class GameConfig {
  static const int brickPrice = 2;
  static const int brickHP = 3;
  static const int bulletPackPrice = 10;
  static const int bulletPackAmount = 12;

  // We calculate "buffedDamage" so that it perfectly matches the amount of bullets you specified 
  // when shooting from inside the house (e.g., Normie has 3 HP. 3 / 1.5 damage = exactly 2 bullets).
  static const Map<String, Map<String, dynamic>> zombieStats = {
    'normie':         {'hp': 3.0,  'coins': 3,  'buffedDamage': 1.5,   'sprite': 'no.png'},   // Needs 3 out, 2 in
    'upper_normie':   {'hp': 5.0,  'coins': 5,  'buffedDamage': 1.25,  'sprite': 'uno.png'},  // Needs 5 out, 4 in
    'greater_normie': {'hp': 7.0,  'coins': 8,  'buffedDamage': 1.17,  'sprite': 'gno.png'},  // Needs 7 out, 6 in
    'mommy':          {'hp': 9.0,  'coins': 10, 'buffedDamage': 1.125, 'sprite': 'mo.png'},   // Needs 9 out, 8 in
    'super_mommy':    {'hp': 12.0, 'coins': 15, 'buffedDamage': 1.2,   'sprite': 'smo.png'},  // Needs 12 out, 10 in
  };
}