enum ExitSide { top, bottom, left, right }

enum LevelDifficulty { easy, medium, hard, expert, legend, master }

extension LevelDifficultyX on LevelDifficulty {
  String get translationKey {
    switch (this) {
      case LevelDifficulty.easy:
        return 'level_select.easy';
      case LevelDifficulty.medium:
        return 'level_select.medium';
      case LevelDifficulty.hard:
        return 'level_select.hard';
      case LevelDifficulty.expert:
        return 'level_select.expert';
      case LevelDifficulty.legend:
        return 'level_select.legend';
      case LevelDifficulty.master:
        return 'level_select.master';
    }
  }
}
