import 'package:flutter/material.dart';
import '../current_store.dart'; // adapte si ton path est différent

class HeaderClientVM extends ChangeNotifier {
  HeaderClientVM() {
    _storeNameFuture = CurrentStoreService.getCurrentStoreName();
  }

  late final Future<String?> _storeNameFuture;
  Future<String?> get storeNameFuture => _storeNameFuture;
}
