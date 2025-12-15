// dart
// File: frontend/dime_flutter/lib/vm/current_connected_account_vm.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth_viewmodel.dart';

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
    required  this.email ,
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

  /// Retourne un acteur du rôle client en utilisant l'AuthViewModel pour obtenir l'ID courant.
  static Future<Client> getCurrentActor({required AuthViewModel auth}) async {
    final actorId = _extractActorId(auth);
    return _fetchActor(
      actorId: actorId,
      expectedRole: ['client'],
      roleLabel: ['client'],
    );
  }

  /// Retourne un acteur du rôle merchant en utilisant l'AuthViewModel pour obtenir l'ID courant.
  static Future<Client> getCurrentMerchant({required AuthViewModel auth}) async {
    final actorId = _extractActorId(auth);
    return _fetchActor(
      actorId: actorId,
      expectedRole: ['owner', 'employee'],
      roleLabel: ['owner', 'employee'],
    );
  }

  /// Helper pour extraire l'actorId depuis AuthViewModel et vérifier la présence.
  static int _extractActorId(AuthViewModel auth) {
    try {
      final id = auth.actorId;
      if (id == null) {
        throw Exception('No users logged in (actor_id absent).');
      }
      return id;
    } catch (e) {
      throw Exception('Unable to extract actorId from the authentication service: $e');
    }
  }

  /// Fait la requête pour avoir les éléments de l'acteur demandé
  static Future<Client> _fetchActor({
    required int actorId,
    required List<String> expectedRole,
    required List<String> roleLabel,
  }) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('actor')
        .select('actor_id, first_name, last_name, role, email')
        .eq('actor_id', actorId)
        .maybeSingle();
    if (response == null) {
      throw Exception('No actor found for ID $actorId');
    }
    final actor = Client(
      actorId: response['actor_id'] as int,
      firstName: response['first_name'] as String,
      lastName: response['last_name'] as String,
      role: response['role'] as String,
      email: response['email'] as String,
    );
    print(actor.role);
    if (expectedRole.contains(actor.role) == false) {
      throw Exception(
        'Access refused : role \\« ${actor.role} \\», expected \\« $roleLabel \\».',
      );
    }

    return actor;
  }
}
