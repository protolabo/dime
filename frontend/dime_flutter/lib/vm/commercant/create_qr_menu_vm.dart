import 'package:flutter/material.dart';

import 'package:dime_flutter/vm/current_store.dart';
import 'package:dime_flutter/view/commercant/create_item_page.dart';
import 'package:dime_flutter/view/commercant/create_shelf.dart';

class CreateQrMenuViewModel extends ChangeNotifier {
  bool isLoading = true;
  String? error;
  String? storeName;

  CreateQrMenuViewModel() {
    _loadStoreName();
  }

  Future<void> _loadStoreName() async {
    try {
      storeName = await CurrentStoreService.getCurrentStoreName();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void goToCreateItem(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateItemPage()),
    );
  }

  void goToCreateShelf(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateShelfPage()),
    );
  }

}
