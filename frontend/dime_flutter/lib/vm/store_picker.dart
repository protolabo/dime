/* Ce fichier est seulement présent en bus de tests. Ce fichier nous permet de choisir facilement le magasin qu'on veut que le client soit présent.*/

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dime_flutter/vm/current_store.dart';

class StorePickerPage extends StatefulWidget {
  const StorePickerPage({super.key});

  @override
  State<StorePickerPage> createState() => _StorePickerPageState();
}

class _StorePickerPageState extends State<StorePickerPage> {
  final _sb = Supabase.instance.client;
  List<Map<String, dynamic>> _stores = [];
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Récuoère tous les magasins du système
  Future<void> _load() async {
    // récupère TOUS les magasins (store_id + name)
    final rows = await _sb.from('store').select('store_id, name');
    final current = await CurrentStoreService.getCurrentStoreId();

    setState(() {
      _stores = List<Map<String, dynamic>>.from(rows);
      _selectedId = current;
    });
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
          return ListTile(
            title: Text(store['name']),
            trailing: isCurrent
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () async {
              await CurrentStoreService.setCurrentStore(
                store['store_id'] as int,
              );
              setState(() => _selectedId = store['store_id'] as int);
              if (mounted) Navigator.pop(context); // ferme la page
            },
          );
        },
      ),
    );
  }
}
