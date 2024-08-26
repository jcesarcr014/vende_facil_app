class AppStateManager {
  String _currentScreen = 'defaultScreen';

  AppStateManager();

  String get currentScreen => _currentScreen;

  void setCurrentScreen(String screen) {
    _currentScreen = screen;
  }
}

AppStateManager manager = AppStateManager();