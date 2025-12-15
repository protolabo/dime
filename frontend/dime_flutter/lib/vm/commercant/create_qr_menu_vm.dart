import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:dime_flutter/vm/current_store.dart';
import 'package:image_picker/image_picker.dart';

import 'package:dime_flutter/view/commercant/create_item_page.dart';
import 'package:dime_flutter/view/commercant/create_shelf.dart';

class CreateQrMenuViewModel extends ChangeNotifier {
  static final String apiBaseUrl = dotenv.env['BACKEND_API_URL'] ?? '';
  bool isLoading = true;
  String? error;
  String? storeName;
  String? storeLogo;
  int? currentStoreId;
  int itemCount = 0;
  int shelfCount = 0;
  bool isUploadingLogo = false;

  final ImagePicker _picker = ImagePicker();

  CreateQrMenuViewModel() {
    _init();
  }

  Future<void> _init() async {
    isLoading = true;
    notifyListeners();

    await _loadStoreName();
    await _loadStats();

    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadStoreName() async {
    try {
      currentStoreId = await CurrentStoreService.getCurrentStoreId();
      if (currentStoreId != null) {
        final response = await http.get(
          Uri.parse('$apiBaseUrl/stores?store_id=$currentStoreId'),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final stores = data['favorites'] as List?;
          if (stores != null && stores.isNotEmpty) {
            storeName = stores[0]['name'] ?? 'Magasin';
            storeLogo = stores[0]['logo_url'];
          }
        }
      }
    } catch (e) {
      error = e.toString();
    }
  }

  Future<void> _loadStats() async {
    try {
      final storeId = await CurrentStoreService.getCurrentStoreId();
      if (storeId == null) return;

      final productsResponse = await http.get(
        Uri.parse('$apiBaseUrl/priced-products?store_id=$storeId'),
      );
      if (productsResponse.statusCode == 200) {
        final data = jsonDecode(productsResponse.body);
        itemCount = (data['pricedProducts'] as List?)?.length ?? 0;
      }

      final shelvesResponse = await http.get(
        Uri.parse('$apiBaseUrl/shelves?store_id=$storeId'),
      );
      if (shelvesResponse.statusCode == 200) {
        final data = jsonDecode(shelvesResponse.body);
        shelfCount = (data['reviews'] as List?)?.length ?? 0;
      }
    } catch (e) {
      // Ignorer les erreurs
    }
  }

  Future<void> pickAndUploadLogo(BuildContext context) async {
    if (currentStoreId == null || isUploadingLogo) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      isUploadingLogo = true;
      notifyListeners();

      final uri = Uri.parse('$apiBaseUrl/stores/$currentStoreId/logo');
      final request = http.MultipartRequest('PUT', uri);

      final bytes = await image.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: image.name,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        storeLogo = json['logo_url'];

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logo Updated ✔')),
          );
        }
      } else {
        throw Exception('Server Error');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error : $e')),
        );
      }
    } finally {
      isUploadingLogo = false;
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
