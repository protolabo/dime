import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/vm/components/header_client_vm.dart';
import 'package:dime_flutter/vm/store_picker.dart'; // adapte au besoin
import 'package:dime_flutter/main.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header(this.explicitStoreName, {super.key});
  final String? explicitStoreName;

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HeaderClientVM(),
      child: _HeaderView(explicitStoreName),
    );
  }
}

/*───────────────────────────────────────────*/

class _HeaderView extends StatelessWidget {
  const _HeaderView(this.explicitStoreName);
  final String? explicitStoreName;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HeaderClientVM>();

    return Container(
      color: AppColors.searchBg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: FutureBuilder<String?>(
            future: vm.storeNameFuture,
            builder: (context, snap) {
              final storeName =
                  explicitStoreName ?? snap.data ?? 'Choose a store';

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /* ─────────── icône adresse ─────────── */
                  SvgPicture.asset(
                    'assets/icons/address-icon.svg',
                    height: 26,
                    colorFilter: const ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),

                  /* ────── bloc “Currently at / nom” ────── */
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StorePickerPage(),
                          ),
                        );
                        context.read<HeaderClientVM>().reloadStoreName();
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Currently at:',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              /* nom du commerce – wrap autorisé */
                              Expanded(
                                child: Text(
                                  storeName,
                                  style: AppTextStyles.title.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  softWrap: true,
                                  maxLines: 2, // s’il doit passer sur 2 lignes
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  /* ─────────── Logout ─────────── */
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
                      height: 26,
                      colorFilter: const ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
                      ),
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
