import 'package:flutter/material.dart';

typedef FavoriteChanged = void Function(bool isNowFavorited);

class FavItemFenetre extends StatefulWidget {
  final String name;
  final bool isFavorite;
  final FavoriteChanged onFavoriteChanged;

  const FavItemFenetre({
    super.key,
    required this.name,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  @override
  _FavItemFenetreState createState() => _FavItemFenetreState();
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
        color: const Color(0xFFFDF1DC),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Stack(
        children: [
          // Nom de l'item centré
          Center(
            child: Text(
              widget.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontFamily: 'Poppins'),
            ),
          ),
          // Cœur en haut à droite à l'intérieur du carré
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: _toggleFavorite,
              child: Icon(
                Icons.favorite,
                size: 28,
                color: _isFavorited ? Colors.red : Colors.white,
                shadows: [
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
