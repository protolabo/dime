import 'package:flutter/material.dart';

/// VM pour la barre de navigation du côté commerçant.
/// - Conserve l’index sélectionné
/// - Notifie la vue pour refléter la sélection
class NavBarCommercantVM extends ChangeNotifier {
  NavBarCommercantVM({int initialIndex = 0}) : _currentIndex = initialIndex;

  int _currentIndex;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
  }
}
