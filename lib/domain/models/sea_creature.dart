enum CreatureType {
  friendly,
  dangerous,
}

class SeaCreature {
  final String name;
  final String imageAsset;
  final CreatureType type;
  final int points;

  const SeaCreature({
    required this.name,
    required this.imageAsset,
    required this.type,
    required this.points,
  });

  bool get isFriendly => type == CreatureType.friendly;
  bool get isDangerous => type == CreatureType.dangerous;
}

abstract class CreatureRule {
  bool shouldRespond(SeaCreature creature);
  String get instruction;
}

class FriendlyCreatureRule implements CreatureRule {
  @override
  bool shouldRespond(SeaCreature creature) => creature.isFriendly;

  @override
  String get instruction => 'Tap friendly sea creatures!';
}

class DangerousCreatureRule implements CreatureRule {
  @override
  bool shouldRespond(SeaCreature creature) => creature.isDangerous;

  @override
  String get instruction => 'Tap dangerous sea creatures!';
}

class GoNoGoService {
  final CreatureRule _currentRule;
  int _score = 0;
  int _consecutiveCorrect = 0;
  static const int _pointsForCorrect = 10;
  static const int _pointsForIncorrect = -5;

  GoNoGoService(this._currentRule);

  int get score => _score;
  int get consecutiveCorrect => _consecutiveCorrect;
  CreatureRule get currentRule => _currentRule;

  bool handleResponse(SeaCreature creature, bool didRespond) {
    final shouldHaveResponded = _currentRule.shouldRespond(creature);
    final isCorrect = shouldHaveResponded == didRespond;

    if (isCorrect) {
      _score += _pointsForCorrect;
      _consecutiveCorrect++;
    } else {
      _score = _score + _pointsForIncorrect;
      if (_score < 0) _score = 0;
      _consecutiveCorrect = 0;
    }

    return isCorrect;
  }

  void resetGame() {
    _score = 0;
    _consecutiveCorrect = 0;
  }
} 