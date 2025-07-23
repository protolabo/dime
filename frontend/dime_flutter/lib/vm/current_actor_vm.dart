import 'package:supabase_flutter/supabase_flutter.dart';

/// Représente ton acteur (utilisateur) connecté
class Actor {
  final int actorId;
  final String firstName;
  final String lastName;
  final String role;

  Actor({
    required this.actorId,
    required this.firstName,
    required this.lastName,
    required this.role,
  });
}

class CurrentActorService {
  // Pour l’instant on “hardcode” l’actor_id=1
  static const int _testActorId = 1;

  /// Charge l’acteur depuis la table `actor` et vérifie qu’il est client
  static Future<Actor> getCurrentActor() async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('actor')
        .select('actor_id, first_name, last_name, role')
        .eq('actor_id', _testActorId)
        .maybeSingle();

    if (response == null) {
      throw Exception('Aucun acteur trouvé pour ID $_testActorId');
    }

    final actor = Actor(
      actorId: response['actor_id'] as int,
      firstName: response['first_name'] as String,
      lastName: response['last_name'] as String,
      role: response['role'] as String,
    );

    if (actor.role != 'client') {
      throw Exception(
        'Accès refusé : rôle de l’acteur est "${actor.role}", attendu "client".',
      );
    }

    return actor;
  }
}
