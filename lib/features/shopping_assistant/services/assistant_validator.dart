import '../domain/enums/assistant_intent.dart';

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
  });
}

class AssistantValidator {
  ValidationResult validate(Map<String, dynamic> json) {
    final errors = <String>[];

    if (json.isEmpty) {
      errors.add('payload vacío');
      return ValidationResult(isValid: false, errors: errors);
    }

    final conversationId = json['conversationId'];
    if (conversationId == null ||
        (conversationId is String && conversationId.isEmpty)) {
      errors.add('conversationId ausente o vacío');
    }

    final type = json['type'];
    if (type == null || (type is String && type.isEmpty)) {
      errors.add('type ausente o vacío');
    } else if (type is String) {
      try {
        AssistantIntent.fromJson(type);
      } catch (_) {
        errors.add('tipo desconocido: $type');
      }
    }

    final payload = json['payload'];
    if (payload == null) {
      errors.add('payload vacío');
    } else if (payload is Map && payload.isEmpty) {
      errors.add('payload vacío');
    }

    final timestamp = json['timestamp'];
    if (timestamp == null || (timestamp is String && timestamp.isEmpty)) {
      errors.add('timestamp ausente o vacío');
    } else if (timestamp is String) {
      try {
        DateTime.parse(timestamp);
      } catch (_) {
        errors.add('timestamp inválido: $timestamp');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}
