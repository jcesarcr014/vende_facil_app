class AppStateManager {
  late String _currentScreen;

  AppStateManager();

  String get currentScreen => _currentScreen;

  void setCurrentScreen(String screen) {
    _currentScreen = screen;
  }
}

AppStateManager manager = AppStateManager();