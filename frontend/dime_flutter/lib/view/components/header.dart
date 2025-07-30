import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dime_flutter/vm/current_store.dart';
import 'package:dime_flutter/vm/store_picker.dart'; // chemin ↦ lib/view/store_picker.dart

class Header extends StatefulWidget implements PreferredSizeWidget {
  final String? nameCommerce;
  const Header(this.nameCommerce, {super.key});

  @override
  State<Header> createState() => _HeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _HeaderState extends State<Header> {
  late Future<String?> _storeNameFuture;

  @override
  void initState() {
    super.initState();
    _storeNameFuture = CurrentStoreService.getCurrentStoreName();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFDF1DC),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: FutureBuilder<String?>(
            future: _storeNameFuture,
            builder: (context, snapshot) {
              final name =
                  widget.nameCommerce ?? snapshot.data ?? 'Choisir un magasin';

              return Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/address-icon.svg',
                    height: 28,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),

                  // 👉 ouvre StorePickerPage
                  InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StorePickerPage(),
                        ),
                      );
                      if (mounted) {
                        setState(() {
                          _storeNameFuture =
                              CurrentStoreService.getCurrentStoreName();
                        });
                      }
                    },
                    child: Text(
                      'Currently at:\n$name',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // icône logout (optionnel — garde-le si tu l’utilises déjà)
                  SvgPicture.asset(
                    'assets/icons/logout.svg',
                    height: 28,
                    color: Colors.black,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
