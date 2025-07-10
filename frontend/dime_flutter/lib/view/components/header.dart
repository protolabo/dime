import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Header extends StatelessWidget {
  final String nameCommerce;

  const Header(this.nameCommerce, {super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFFFFF2D9),
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ───── Section « Currently at » ─────
          GestureDetector(
            onTap: () {
              debugPrint("Nom du commerce cliqué");
            },
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/address-icon.svg',
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Currently at:',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    Text(
                      nameCommerce,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ───── Bouton logout ─────
          GestureDetector(
            onTap: () {
              debugPrint("Logout cliqué");
            },
            child: SvgPicture.asset(
              'assets/icons/logout.svg',
              height: 28,
              width: 28,
            ),
          ),
        ],
      ),
    );
  }
}
