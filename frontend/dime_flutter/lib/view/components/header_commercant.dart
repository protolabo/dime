import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/view/commercant/choose_commerce.dart';
import 'package:dime_flutter/vm/components/header_commercant_vm.dart';
import 'package:dime_flutter/main.dart';

import '../../auth_viewmodel.dart';

class HeaderCommercant extends StatelessWidget implements PreferredSizeWidget {
  const HeaderCommercant({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(88);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HeaderCommercantVM(auth: context.read<AuthViewModel>())..load(),
      child: const _HeaderCommercantView(),
    );
  }
}

/*──────────────────────────────────────────────────────────────*/

class _HeaderCommercantView extends StatelessWidget {
  const _HeaderCommercantView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HeaderCommercantVM>();
    final double ownerBlockWidth = 140;

    final storeName = vm.isLoading ? '...' : vm.storeName;
    final ownerName = vm.isLoading ? '...' : vm.ownerName;

    return Material(
      color: AppColors.searchBg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.store, size: 28),
              const SizedBox(width: 10),

              // ── Bloc magasin
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
                    )
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ── Bloc propriétaire
              SizedBox(
                width: ownerBlockWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Welcome',
                        style: AppTextStyles.body.copyWith(fontSize: 13)),
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

              // ── Bouton logout
              IconButton(
                splashRadius: 22,
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MyApp()),
                      (_) => false,
                ),
                icon: SvgPicture.asset(
                  'assets/icons/logout.svg',
                  height: 22,
                  colorFilter:
                  const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
