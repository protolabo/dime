import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../vm/choose_commerce_vm.dart';        // ← corrige le chemin si besoin
import '../styles.dart';                   // ← nouveau

class ChooseCommercePage extends StatelessWidget {
  const ChooseCommercePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChooseCommerceViewModel(),
      child: Consumer<ChooseCommerceViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (vm.error != null) {
            return Scaffold(
              body: Center(child: Text('Erreur : ${vm.error}')),
            );
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Pick a commerce')),
            body: Padding(
              padding: AppPadding.all, // déjà défini dans styles.dart
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: 1,
                ),
                itemCount: vm.stores.length,
                itemBuilder: (context, index) {
                  final store = vm.stores[index];
                  return GestureDetector(
                    onTap: () => vm.selectStore(context, store),
                    child: Container(
                      decoration: BoxDecoration(
                        color: ChooseCommerceStyles.tileBg,
                        border: Border.fromBorderSide(
                          ChooseCommerceStyles.tileBorder,
                        ),
                        borderRadius: AppRadius.border,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            store['name'],
                            textAlign: TextAlign.center,
                            style: ChooseCommerceStyles.tileText,
                          ),
                          const SizedBox(height: 12),
                          const Icon(Icons.store,
                              size: ChooseCommerceStyles.iconSize),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
