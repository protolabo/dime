import 'package:flutter/material.dart';
import 'package:dime_flutter/view/styles.dart';

typedef FavoriteChanged = void Function(bool isNowFavorited);

class FavItemFenetre extends StatefulWidget {
  const FavItemFenetre({
    Key? key,
    required this.name,
    required this.isFavorite,
    required this.onFavoriteChanged,
  }) : super(key: key);

  final String           name;
  final bool             isFavorite;
  final FavoriteChanged  onFavoriteChanged;

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
      width : 140,
      height: 140,
      decoration: BoxDecoration(
        color : AppColors.searchBg,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Stack(
        children: [
          /* ─── Nom de l’item ─── */
          Center(
            child: Text(
              widget.name,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                fontSize : 16,
                fontFamily: 'Poppins',
              ),
            ),
          ),

          /* ─── Cœur favori ─── */
          Positioned(
            top : 6,
            right: 6,
            child: GestureDetector(
              onTap : _toggleFavorite,
              child : Icon(
                Icons.favorite,
                size : 28,
                color: _isFavorited ? AppColors.danger : Colors.white,
                shadows: const [
                  Shadow(
                    blurRadius: 4,
                    offset   : Offset(1, 1),
                    color    : Colors.black26,
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
