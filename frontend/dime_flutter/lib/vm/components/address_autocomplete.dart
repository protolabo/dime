import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';

class AddressAutocomplete extends StatefulWidget {
  final TextEditingController addressController;
  final void Function(Map<String, dynamic> placeDetails)? onPlaceSelected;

  const AddressAutocomplete({
    super.key,
    required this.addressController,
    this.onPlaceSelected,
  });

  @override
  State<AddressAutocomplete> createState() => _AddressAutocompleteState();
}

class _AddressAutocompleteState extends State<AddressAutocomplete> {
  final String _apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
  late final FlutterGooglePlacesSdk _places;
  final FocusNode _focusNode = FocusNode();
  List<AutocompletePrediction> _predictions = [];
  bool _isLoading = false;
  bool _hasSelected = false; // empêche recherche juste après sélection

  @override
  void initState() {
    super.initState();
    _places = FlutterGooglePlacesSdk(_apiKey);
    widget.addressController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.addressController.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) {
          setState(() => _predictions = []);
        }
      });
    }
  }

  void _onTextChanged() {
    final query = widget.addressController.text.trim();

    // Si l'utilisateur modifie le texte après une sélection : réactivation
    if (_hasSelected) {
      _hasSelected = false;
    }

    if (query.length < 3) {
      setState(() => _predictions = []);
      return;
    }

    _fetchPredictions(query);
  }

  Future<void> _fetchPredictions(String query) async {
    setState(() => _isLoading = true);
    try {
      final result = await _places.findAutocompletePredictions(
        query,
        countries: ['ca'],
        newSessionToken: false,
      );
      if (mounted) {
        setState(() => _predictions = result.predictions);
      }
    } catch (e) {
      debugPrint('Erreur Places: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectPrediction(AutocompletePrediction prediction) async {
    final description = prediction.fullText;

    setState(() {
      _hasSelected = true; // bloque _onTextChanged juste après sélection
      _predictions = [];   // fermer immédiatement les suggestions
      _isLoading = true;
    });

    widget.addressController.text = description;
    widget.addressController.selection = TextSelection.fromPosition(
      TextPosition(offset: description.length),
    );

    _focusNode.unfocus();

    String city = '';
    String postalCode = '';

    try {
      final details = await _places.fetchPlace(
        prediction.placeId,
        fields: [PlaceField.AddressComponents, PlaceField.Address],
      );

      final components = details.place?.addressComponents ?? [];

      for (final comp in components) {
        if (comp.types.contains('locality')) {
          city = comp.name;
        } else if (comp.types.contains('postal_code')) {
          postalCode = comp.name;
        }
      }
    } catch (e) {
      debugPrint('Erreur fetchPlace: $e');
      final parts = description.split(',').map((e) => e.trim()).toList();
      if (parts.length >= 3) {
        city = parts[parts.length - 3];
      } else if (parts.length >= 2) {
        city = parts[0];
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    widget.onPlaceSelected?.call({
      'formatted_address': description,
      'city': city,
      'postal_code': postalCode,
      'country': 'Canada',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.addressController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Rechercher une adresse...',
            hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
            filled: true,
            fillColor: const Color(0xFFF0F0F5),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            suffixIcon: _isLoading
                ? const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : const Icon(Icons.search, color: Color(0xFF666666)),
          ),
          validator: (v) => v?.isEmpty ?? true ? 'Adresse requise' : null,
        ),

        if (_predictions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Color(0x22000000), blurRadius: 8),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final p = _predictions[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on_outlined, size: 20),
                  title: Text(
                    p.primaryText,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    p.secondaryText,
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () => _selectPrediction(p),
                );
              },
            ),
          ),
      ],
    );
  }
}
