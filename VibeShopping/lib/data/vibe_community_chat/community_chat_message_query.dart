import 'package:supabase_flutter/supabase_flutter.dart';


/// Consultas Supabase para el foro: excluye mensajes con más de 24 h de antigüedad.
class CommunityChatMessageQuery {
  CommunityChatMessageQuery(this._supabase);

  final SupabaseClient _supabase;

  /// Nombre de la tabla de mensajes.
  static const String tableName = 'community_messages';

  /// Nombre del campo de marca de tiempo.
  static const String defaultTimestampField = 'createdAt';

  /// Consulta de mensajes visibles en tiempo real: `createdAt` > ahora − 24 h.
  Stream<List<Map<String, dynamic>>> visibleMessagesStream({
    String timestampField = defaultTimestampField,
    Duration maxAge = VibeBusinessRules.forumMessageVisibility,
  }) {
    final cutoffUtc = DateTime.now().toUtc().subtract(maxAge);
    return _supabase
        .from(tableName)
        .stream(primaryKey: ['id'])
        .gt(timestampField, cutoffUtc.toIso8601String())
        .order(timestampField, ascending: false);
  }
}

class VibeBusinessRules {
  /// Duración máxima para que un mensaje del foro sea visible.
  static const Duration forumMessageVisibility = Duration(hours: 24);
}
