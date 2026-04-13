import 'package:cloud_firestore/cloud_firestore.dart';

import '../../vibe_core/vibe_constants.dart';

/// Consultas Firestore para el foro: excluye mensajes con más de 24 h de antigüedad.
///
/// Requiere índice compuesto en Firestore si usas `orderBy` + `where` en el mismo campo.
class CommunityChatMessageQuery {
  CommunityChatMessageQuery(this._firestore);

  final FirebaseFirestore _firestore;

  /// Nombre del campo de marca de tiempo (ajustar al esquema real de la colección).
  static const String defaultTimestampField = 'createdAt';

  /// Consulta de mensajes visibles: `createdAt` > ahora − 24 h.
  Query<Map<String, dynamic>> visibleMessages({
    required String collectionPath,
    String timestampField = defaultTimestampField,
    Duration maxAge = VibeBusinessRules.forumMessageVisibility,
  }) {
    final cutoff = DateTime.now().subtract(maxAge);
    return _firestore
        .collection(collectionPath)
        .where(timestampField, isGreaterThan: Timestamp.fromDate(cutoff))
        .orderBy(timestampField, descending: true);
  }
}
