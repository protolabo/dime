import 'package:flutter/material.dart';
import 'package:dime_flutter/view/styles.dart';

typedef FavoriteChanged = void Function(bool isNowFavorited);

class FavItemFenetre extends StatefulWidget {
  const FavItemFenetre({
    super.key,
    required this.name,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  final String name;
  final bool isFavorite;
  final FavoriteChanged onFavoriteChanged;

  @override
  State<FavItemFenetre> createState() => _FavItemFenetreState();
}

class _FavItemFenetreState extends State<FavItemFenetre> {
  late bool _isFavorited;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.isFavorite;
  }

  void _toggleFavorite() {
    setState(() => _isFavorited = !_isFavorited);
    widget.onFavoriteChanged(_isFavorited);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        // ⬇️ Exactement comme choose_commerce
        color: ChooseCommerceStyles.tileBg,
        border: Border.fromBorderSide(ChooseCommerceStyles.tileBorder),
        borderRadius: AppRadius.border,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Nom de l’item (même style que choose_commerce)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text(
                widget.name,
                textAlign: TextAlign.center,
                style: ChooseCommerceStyles.tileText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Cœur favori
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: _toggleFavorite,
              child: Icon(
                Icons.favorite,
                size: 28,
                color: _isFavorited ? AppColors.danger : Colors.white,
                shadows: const [
                  Shadow(
                    blurRadius: 4,
                    offset: Offset(1, 1),
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
