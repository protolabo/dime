import 'package:supabase_flutter/supabase_flutter.dart';

/// Représente un acteur (utilisateur) de l’application.
class Client {
  final int actorId;
  final String firstName;
  final String lastName;
  final String role;
  final String email;

  Client({
    required this.actorId,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.email,
  });
}

class CurrentActorService {
  /*
  * Id existant:
  *
  * 1: John Doe (client)
  * 2: Donald D. Epstein (commercant)
  * 3: L-E Lafontant (commercant)
  * 4: DB (client)
  *
  * */





  /*─────────────────── IDs de test ────────────────────*/
  // 1 → compte client (déjà utilisé partout dans l’app)
  static const int _testActorId       = 4;
  // 2 → compte commerçant (nouveau pour le côté merchant)
  static const int _testMerchantId    = 2;


  /// Retourne un acteur du rôle client
  static Future<Client> getCurrentActor() async {
    return _fetchActor(
      actorId: _testActorId,
      expectedRole: 'client',
      roleLabel: 'client',
    );
  }


  /// Retourne un acteur du rôle client
  static Future<Client> getCurrentMerchant() async {
    return _fetchActor(
      actorId: _testMerchantId,
      expectedRole: 'merchant',
      roleLabel: 'merchant',
    );
  }

  /// Fait la requête pour avoir les éléments de l'acteur demandé
  static Future<Client> _fetchActor({
    required int actorId,
    required String expectedRole,
    required String roleLabel,
  }) async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('actor')
         .select('actor_id, first_name, last_name, role, email')
        .eq('actor_id', actorId)
        .maybeSingle();

    if (response == null) {
      throw Exception('Aucun acteur trouvé pour ID $actorId');
    }

    final actor = Client(
      actorId: response['actor_id'] as int,
      firstName: response['first_name'] as String,
      lastName: response['last_name'] as String,
      role: response['role'] as String,
      email: response['email'] as String,
    );

    if (actor.role != expectedRole) {
      throw Exception(
        'Accès refusé : rôle « ${actor.role} », attendu « $roleLabel ».',
      );
    }

    return actor;
  }
}
