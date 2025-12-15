import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:dime_flutter/vm/current_store.dart';
import 'package:dime_flutter/vm/current_connected_account_vm.dart';
import '../../auth_viewmodel.dart';

class CreateShelfViewModel extends ChangeNotifier {
  static final String apiBaseUrl = dotenv.env['BACKEND_API_URL'] ?? '';
  final AuthViewModel auth;
  String? qrDataUrl;
  String? errorMessage;

  CreateShelfViewModel({required this.auth});

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  XFile? _selectedImage;
  XFile? get selectedImage => _selectedImage;

  void setImage(XFile? image) {
    _selectedImage = image;
    notifyListeners();
  }

  Future<void> saveShelf({
    required String shelfName,
    required BuildContext context,
  }) async {
    if (shelfName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to enter a name for the shelf.')),
      );
      return;
    }

    _isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final storeId = await CurrentStoreService.getCurrentStoreId();
      if (storeId == null) {
        errorMessage = 'No commerce selected.';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select a Store first.')),
        );
        _isSaving = false;
        notifyListeners();
        return;
      }

      final merchant = await CurrentActorService.getCurrentMerchant(auth: auth);
      final createdBy = merchant.email;

      // Création de l'étagère
      final uri = Uri.parse('$apiBaseUrl/shelves');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'shelfName': shelfName,
          'store_id': storeId.toString(),
          'location': '',
          'created_by': createdBy,
        }),
      );

      if (response.statusCode == 201) {
        final json = Map<String, dynamic>.from(jsonDecode(response.body));
        final shelf = json['shelf'] as Map<String, dynamic>?;
        final shelfId = shelf?['shelf_id'];

        // Upload de l'image si sélectionnée
        if (_selectedImage != null && shelfId != null) {
          await _uploadShelfImage(shelfId);
        }

        _selectedImage = null;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shelf Created ✔')),
          );
        }
      } else {
        errorMessage = 'server error (${response.statusCode})';
      }
    } catch (e) {
      errorMessage = 'Error : $e';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> _uploadShelfImage(int shelfId) async {
    if (_selectedImage == null) return;

    try {
      final uri = Uri.parse('$apiBaseUrl/shelves/$shelfId/image');
      final request = http.MultipartRequest('PUT', uri);

      final bytes = await _selectedImage!.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: _selectedImage!.name,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        errorMessage = 'Error while uploading image';
      }
    } catch (e) {
      errorMessage = 'Error upload : $e';
    }
  }
}
