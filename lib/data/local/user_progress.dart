class SettingsModel {
  final bool sound;
  final bool music;
  final bool haptics;
  final bool vibration;
  final String languageCode;

  const SettingsModel({
    this.sound = true,
    this.music = true,
    this.haptics = true,
    this.vibration = true,
    this.languageCode = 'en',
  });

  SettingsModel copyWith({
    bool? sound,
    bool? music,
    bool? haptics,
    bool? vibration,
    String? languageCode,
  }) {
    return SettingsModel(
      sound: sound ?? this.sound,
      music: music ?? this.music,
      haptics: haptics ?? this.haptics,
      vibration: vibration ?? this.vibration,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  Map<String, dynamic> toJson() => {
    'sound': sound,
    'music': music,
    'haptics': haptics,
    'vibration': vibration,
    'languageCode': languageCode,
  };

  factory SettingsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SettingsModel();
    return SettingsModel(
      sound: json['sound'] as bool? ?? true,
      music: json['music'] as bool? ?? true,
      haptics: json['haptics'] as bool? ?? true,
      vibration: json['vibration'] as bool? ?? true,
      languageCode: json['languageCode'] as String? ?? 'en',
    );
  }
}

class UserProgress {
  final int schemaVersion;
  final int unlockedLevel;
  final int currentLevel;
  final Map<int, int> stars;
  final SettingsModel settings;

  const UserProgress({
    this.schemaVersion = 1,
    this.unlockedLevel = 1,
    this.currentLevel = 1,
    this.stars = const {},
    this.settings = const SettingsModel(),
  });

  UserProgress copyWith({
    int? schemaVersion,
    int? unlockedLevel,
    int? currentLevel,
    Map<int, int>? stars,
    SettingsModel? settings,
  }) {
    return UserProgress(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      unlockedLevel: unlockedLevel ?? this.unlockedLevel,
      currentLevel: currentLevel ?? this.currentLevel,
      stars: stars ?? this.stars,
      settings: settings ?? this.settings,
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'unlockedLevel': unlockedLevel,
    'currentLevel': currentLevel,
    'stars': stars.map((k, v) => MapEntry(k.toString(), v)),
    'settings': settings.toJson(),
  };

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    final rawStars = json['stars'] as Map<String, dynamic>?;
    final Map<int, int> parsedStars = {};

    if (rawStars != null) {
      for (final entry in rawStars.entries) {
        final key = int.tryParse(entry.key);
        final value = entry.value as int?;
        if (key != null && value != null) {
          parsedStars[key] = value;
        }
      }
    }

    return UserProgress(
      schemaVersion: json['schemaVersion'] as int? ?? 1,
      unlockedLevel: json['unlockedLevel'] as int? ?? 1,
      currentLevel: json['currentLevel'] as int? ?? 1,
      stars: parsedStars,
      settings: SettingsModel.fromJson(
        json['settings'] as Map<String, dynamic>?,
      ),
    );
  }
}
