import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dime_flutter/view/components/barcode_scanner.dart';

class BarcodeScannerVM extends ChangeNotifier {
  final MobileScannerController controller;
  bool isScanning = false;

  BarcodeScannerVM({MobileScannerController? controller})
      : controller = controller ??
      MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        formats: const [
          BarcodeFormat.qrCode,
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.upcA,
          BarcodeFormat.code128,
          BarcodeFormat.code39,
        ],
      );

  Future<String?> scan(BuildContext context) async {
    if (isScanning) return null;
    isScanning = true;
    notifyListeners();

    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScannerBottom(controller: controller),
    );

    isScanning = false;
    notifyListeners();
    return result;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
