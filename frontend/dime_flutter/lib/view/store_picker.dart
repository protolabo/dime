import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dime_flutter/vm/current_store.dart';

class StorePickerPage extends StatefulWidget {
  const StorePickerPage({super.key});

  @override
  State<StorePickerPage> createState() => _StorePickerPageState();
}

class _StorePickerPageState extends State<StorePickerPage> {
  List<Map<String, dynamic>> _stores = [];
  int? _selectedId;
  Position? _position;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<Position> _determinePosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }

  Future<void> _load() async {
    Position? pos;
    try {
      pos = await _determinePosition();
    } catch (_) {
      pos = null; // si pas de position disponible, on continue quand même
    }

    final rows = await CurrentStoreService.fetchAllStores();
    final current = await CurrentStoreService.getCurrentStoreId();

    setState(() {
      _stores = List<Map<String, dynamic>>.from(rows);
      _selectedId = current;
      _position = pos;
    });
  }

  String _formatDistance(double? meters) {
    print('Formatting distance: $meters');
    if (meters == null) return '—';
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    } else {
      return '${meters.toStringAsFixed(0)} m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choisir un magasin')),
      body: ListView.separated(
        itemCount: _stores.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (_, i) {
          final store = _stores[i];
          final isCurrent = store['store_id'] == _selectedId;
          print('store: $store ${store['latitude']},${store['longitude']}');
          double? lat = (store['latitude'] as num?)?.toDouble();
          double? lng = (store['longitude'] as num?)?.toDouble();

          double? distanceMeters;
          if (_position != null && lat != null && lng != null) {
            distanceMeters = Geolocator.distanceBetween(
              _position!.latitude,
              _position!.longitude,
              lat,
              lng,
            );
          }

          final distanceText = _formatDistance(distanceMeters);

          return ListTile(
            title: Text(store['name']),
            subtitle: Text('Distance: $distanceText'),
            trailing: isCurrent ? const Icon(Icons.check, color: Colors.green) : null,
            onTap: () async {
              await CurrentStoreService.setCurrentStore(store['store_id'] as int);
              setState(() => _selectedId = store['store_id'] as int);
              if (mounted) Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
