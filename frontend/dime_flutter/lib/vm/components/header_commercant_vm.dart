import 'package:flutter/material.dart';

import 'package:dime_flutter/vm/current_store.dart';
import 'package:dime_flutter/vm/current_connected_account_vm.dart';

class HeaderCommercantVM extends ChangeNotifier {
  String _storeName = '';
  Client? _owner;
  bool _loading = true;
  String? _error;

  String get storeName => _storeName;
  Client? get owner => _owner;
  String get ownerName =>
      _owner == null ? '' : '${_owner!.firstName} ${_owner!.lastName}';
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        CurrentStoreService.getCurrentStoreName(), // nom magasin
        CurrentActorService.getCurrentMerchant(),  // propriétaire
      ]);

      _storeName = (results[0] as String?) ?? '';
      _owner = results[1] as Client?;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
