// lib/view/components/header_commercant.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/view/commercant_account/choose_commerce.dart';
import 'package:dime_flutter/vm/current_store.dart';
import 'package:dime_flutter/vm/current_connected_account_vm.dart';
import 'package:dime_flutter/main.dart';

class HeaderCommercant extends StatefulWidget implements PreferredSizeWidget {
  const HeaderCommercant({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(88);
  @override
  State<HeaderCommercant> createState() => _HeaderCommercantState();
}

class _HeaderCommercantState extends State<HeaderCommercant> {
  late final Future<List<Object?>> _info;

  @override
  void initState() {
    super.initState();
    _info = Future.wait([
      CurrentStoreService.getCurrentStoreName(), // nom magasin
      CurrentActorService.getCurrentMerchant(),  // propriétaire
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final double ownerBlockWidth = 140; // largeur fixe pour “Welcome …”
    return Material(
      color: AppColors.searchBg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: FutureBuilder<List<Object?>>(
            future: _info,
            builder: (c, snap) {
              final storeName = (snap.data?[0] as String?) ?? '';
              final owner     = (snap.data?[1] as Client?);
              final ownerName = owner != null
                  ? '${owner.firstName} ${owner.lastName}'
                  : '';

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.store, size: 28),

                  const SizedBox(width: 10),

                  /* ───── Bloc magasin (prend tout l’espace dispo) ───── */
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          storeName,
                          style: AppTextStyles.subtitle.copyWith(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChooseCommercePage(),
                            ),
                          ),
                          child: Text(
                            'Change commerce',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  /* ───── Bloc propriétaire (largeur fixe) ───── */
                  SizedBox(
                    width: ownerBlockWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Welcome',
                            style:
                            AppTextStyles.body.copyWith(fontSize: 13)),
                        Text(
                          ownerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.subtitle.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 4),

                  /* ───── Bouton logout ───── */
                  IconButton(
                    splashRadius: 22,
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MyApp()),
                          (_) => false,
                    ),
                    icon: SvgPicture.asset(
                      'assets/icons/logout.svg',
                      height: 22,
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
