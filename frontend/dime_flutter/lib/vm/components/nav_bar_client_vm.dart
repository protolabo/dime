import 'package:flutter/material.dart';

/// VM pour la barre de navigation client.
///
/// - Conserve l’`index` sélectionné
/// - Notifie la vue pour refléter la sélection
class NavBarClientVM extends ChangeNotifier {
  NavBarClientVM({int initialIndex = 0}) : _currentIndex = initialIndex;

  int _currentIndex;
  int get currentIndex => _currentIndex;

  /// Met à jour l’onglet actif (et déclenche `notifyListeners`)
  void setIndex(int index) {
    if (index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
  }
}
