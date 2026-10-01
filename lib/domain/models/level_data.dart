enum LevelDifficulty { easy, medium, hard, expert, legend, master }

extension LevelDifficultyX on LevelDifficulty {
  String get displayName {
    switch (this) {
      case LevelDifficulty.easy:
        return 'EASY';
      case LevelDifficulty.medium:
        return 'MEDIUM';
      case LevelDifficulty.hard:
        return 'HARD';
      case LevelDifficulty.expert:
        return 'EXPERT';
      case LevelDifficulty.legend:
        return 'LEGEND';
      case LevelDifficulty.master:
        return 'MASTER';
    }
  }
}
