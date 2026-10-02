abstract class PageRoutes {
  static const String root = 'root';
  static const String home = 'home';
  static const String level = 'level';
  static const String game = 'game';
  static const String settings = 'settings';
}

abstract class AppRoutes {
  static const String root = '/';
  static const String home = '/${PageRoutes.home}';
  static const String level = '/${PageRoutes.level}';
  static const String game = '/${PageRoutes.game}';
  static const String settings = '/${PageRoutes.settings}';
}
