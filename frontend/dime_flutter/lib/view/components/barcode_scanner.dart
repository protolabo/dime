import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerBottom extends StatefulWidget {
  final MobileScannerController controller;
  const ScannerBottom({required this.controller, super.key});

  @override
  State<ScannerBottom> createState() => _ScannerBottomState();
}

class _ScannerBottomState extends State<ScannerBottom> {
  bool _detected = false;

  void _onDetect(BarcodeCapture capture) {
    if (_detected) return;
    for (final b in capture.barcodes) {
      final raw = b.rawValue;
      if (raw == null) continue;
      _detected = true;
      Navigator.of(context).pop(raw);
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.64;
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: widget.controller,
                  onDetect: _onDetect,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton(
                    icon: const Icon(Icons.flash_on),
                    color: Colors.white,
                    onPressed: () => widget.controller.toggleTorch(),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            label: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}
