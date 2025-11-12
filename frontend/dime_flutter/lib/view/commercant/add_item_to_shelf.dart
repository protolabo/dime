import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/view/components/header_commercant.dart';

import 'package:dime_flutter/vm/commercant/add_item_to_shelf_vm.dart';

import '../../auth_viewmodel.dart';

class AddItemToShelfPage extends StatelessWidget {
  const AddItemToShelfPage({
    super.key,
    required this.shelfId,
    required this.shelfName,
  });

  final int shelfId;
  final String shelfName;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddItemToShelfVM(shelfId: shelfId, shelfName: shelfName,auth: context.read<AuthViewModel>())..init(),
      child: const _AddItemToShelfBody(),
    );
  }
}

class _AddItemToShelfBody extends StatelessWidget {
  const _AddItemToShelfBody({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddItemToShelfVM>();
    final media = MediaQuery.of(context);

    return Scaffold(
      appBar: const HeaderCommercant(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: AppPadding.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add items', style: AppTextStyles.title),
                  const SizedBox(height: 4),
                  Text('Shelf: ${vm.shelfName}', style: AppTextStyles.muted),
                  const SizedBox(height: 12),

                  // Mode switch
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Search'),
                        selected: vm.mode == AddItemMode.search,
                        onSelected: (_) => vm.setMode(AddItemMode.search),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Scan'),
                        selected: vm.mode == AddItemMode.scan,
                        onSelected: (_) => vm.setMode(AddItemMode.scan),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Selected chips
                  if (vm.selected.isNotEmpty) _SelectedChips(vm: vm),
                ],
              ),
            ),

            // Body area
            Expanded(
              child: vm.mode == AddItemMode.search
                  ? const _SearchArea()
                  : _ScanArea(mediaPadding: media.padding),
            ),

            // Confirm button
            Padding(
              padding: AppPadding.all,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: vm.selected.isEmpty || vm.saving ? null : () async {
                    final ok = await vm.confirmInsert();
                    if (!context.mounted) return;
                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Items added to shelf.')),
                      );
                      Navigator.pop(context, true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(vm.lastMessage ?? 'Insert failed')),
                      );
                    }
                  },
                  child: Text(vm.saving ? 'Saving…' : 'Confirm (${vm.selected.length})'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ─────────── SEARCH MODE ─────────── */
class _SearchArea extends StatelessWidget {
  const _SearchArea();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddItemToShelfVM>();

    return Column(
      children: [
        Padding(
          padding: AppPadding.h,
          child: TextField(
            controller: vm.searchCtrl,
            onChanged: vm.onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Search a product in this store…',
              prefixIcon: const Icon(Icons.search),
              border: AppBorders.input,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: vm.searching
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: vm.results.length,
            itemBuilder: (contextItem, i) {
              final r = vm.results[i];
              final already = vm.alreadyOnShelf.contains(r.productId);
              final chosen  = vm.selected.containsKey(r.productId);

              return ListTile(
                title: Text(r.name, overflow: TextOverflow.ellipsis),
                subtitle: already ? const Text('Already on this shelf') : null,
                trailing: IconButton(
                  icon: Icon(chosen ? Icons.check : Icons.add),
                  onPressed: already
                      ? null
                      : () async {
                    final res = await vm.addProduct(r.productId, r.name);

                    // Si ta version de Flutter ne supporte pas context.mounted,
                    // tu peux supprimer ce guard.
                    if (!contextItem.mounted) return;

                    if (res.added) {
                      ScaffoldMessenger.of(contextItem).showSnackBar(
                        SnackBar(content: Text('Added: ${r.name}')),
                      );
                    } else if (res.reason != null) {
                      ScaffoldMessenger.of(contextItem).showSnackBar(
                        SnackBar(content: Text(res.reason!)),
                      );
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/* ─────────── SCAN MODE ─────────── */
class _ScanArea extends StatelessWidget {
  const _ScanArea({required this.mediaPadding});
  final EdgeInsets mediaPadding;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddItemToShelfVM>();

    return Stack(
      children: [
        // Camera
        LayoutBuilder(
          builder: (ctx, constraints) {
            final previewSize = constraints.biggest;
            const fit = BoxFit.cover;
            return MobileScanner(
              fit: fit,
              controller: vm.scanner,
              onDetect: (cap) => vm.onDetect(
                cap,
                ctx,
                previewSize: previewSize,
                boxFit: fit,
              ),
            );
          },
        ),

        // Overlay when a product is detected
        if (vm.overlayProduct != null)
          Positioned(
            top: vm.qrRect != null
                ? _clampTop(mediaPadding, vm.qrRect!.bottom + 12, MediaQuery.of(context).size.height)
                : null,
            left: 16,
            right: 16,
            bottom: vm.qrRect == null ? 32 : null,
            child: _ProductOverlay(vm: vm),
          ),
      ],
    );
  }

  double _clampTop(EdgeInsets pad, double desiredTop, double screenH) {
    const cardH = 96.0;
    final maxTop = screenH - pad.bottom - 16 - cardH;
    return desiredTop.clamp(pad.top + 16, maxTop);
  }
}

class _ProductOverlay extends StatelessWidget {
  const _ProductOverlay({required this.vm});
  final AddItemToShelfVM vm;

  @override
  Widget build(BuildContext context) {
    final p = vm.overlayProduct!;
    final already = vm.alreadyOnShelf.contains(p.id) || vm.selected.containsKey(p.id);

    return Container(
      padding: AppPadding.all,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.78),
        borderRadius: AppRadius.border,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              p.name ?? 'Unknown item',
              style: AppTextStyles.subtitle.copyWith(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: 'Add',
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: already
                ? null
                : () async {
              final res = await vm.addProduct(p.id, p.name ?? 'Item');
              if (!context.mounted) return;
              final msg = res.added
                  ? 'Added: ${p.name ?? p.id}'
                  : (res.reason ?? 'Not added');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
            },
          ),
          IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: vm.clearOverlay,
          ),
        ],
      ),
    );
  }
}

/* ─────────── Selected chips ─────────── */
class _SelectedChips extends StatelessWidget {
  const _SelectedChips({required this.vm});
  final AddItemToShelfVM vm;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: vm.selected.entries.map((e) {
        return Chip(
          label: Text(e.value, overflow: TextOverflow.ellipsis),
          onDeleted: () => vm.removeSelected(e.key),
        );
      }).toList(),
    );
  }
}
