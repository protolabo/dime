import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dime_flutter/vm/current_store.dart';
import 'package:dime_flutter/main.dart';

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
      color: const Color(0xFFFDF1DC), // ✅ couvre tout le fond
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: FutureBuilder<String?>(
            future: _storeNameFuture,
            builder: (context, snapshot) {
              final name =
                  widget.nameCommerce ??
                  snapshot.data ??
                  'CommerceInconnueBoss';

              return Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/address-icon.svg',
                    height: 28,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Currently at:\n$name',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const MyApp(),
                        ), // ou HomePage() si t'extrais la home
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: SvgPicture.asset(
                      'assets/icons/logout.svg',
                      height: 28,
                      color: Colors.black,
                    ),
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
