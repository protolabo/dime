import 'package:flutter/material.dart';
import '../current_store.dart'; // adapte si ton path est différent

class HeaderClientVM extends ChangeNotifier {
  HeaderClientVM() {
    _storeNameFuture = CurrentStoreService.getCurrentStoreName();
  }

  late Future<String?> _storeNameFuture;
  Future<String?> get storeNameFuture => _storeNameFuture;

  void reloadStoreName() {
    _storeNameFuture = CurrentStoreService.getCurrentStoreName();
    notifyListeners();
  }
}

