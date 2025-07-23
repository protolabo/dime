import 'package:supabase_flutter/supabase_flutter.dart';
import 'current_actor_vm.dart';
import '../view/client/favorite_menu.dart'; // Pour le modèle Product


/// Modèle Produit (id + nom)
class Product {
  final int id;
  final String name;
  Product(this.id, this.name);
}
/// Service qui charge les produits favoris pour un acteur donné.
class FavoriteProductService {
  /// Récupère la liste des Product (id + name) depuis favorite_product
  static Future<List<Product>> fetchFavorites(int actorId) async {
    final supabase = Supabase.instance.client;
    final data =
        await supabase
                .from('favorite_product')
                .select('product_id, product(name)')
                .eq('actor_id', actorId)
            as List<dynamic>;

    return data.map((row) {
      return Product(
        row['product_id'] as int,
        (row['product'] as Map<String, dynamic>)['name'] as String,
      );
    }).toList();
  }
}
