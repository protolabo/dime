import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:dime_flutter/vm/current_store.dart';
import 'package:dime_flutter/vm/store_picker.dart';
import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/main.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  const Header(this.nameCommerce, {super.key});
  final String? nameCommerce;

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  State<Header> createState() => _HeaderState();
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
      color: AppColors.searchBg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical  : 12,
          ),
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
                    colorFilter: const ColorFilter.mode(
                        Colors.black, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 8),

                  /* ─── Ouvre StorePicker ─── */
                  InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StorePickerPage()),
                      );
                      if (mounted) {
                        setState(() =>
                        _storeNameFuture =
                            CurrentStoreService.getCurrentStoreName());
                      }
                    },
                    child: Text(
                      'Currently at:\n$name',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const Spacer(),

                  /* ─── Logout ─── */
                  IconButton(
                    splashRadius: 22,
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MyApp()),
                            (_) => false,
                      );
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/logout.svg',
                      height: 28,
                      colorFilter: const ColorFilter.mode(
                          Colors.black, BlendMode.srcIn),
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
