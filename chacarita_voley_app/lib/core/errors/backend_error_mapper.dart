import 'dart:convert';

class BackendErrorMapper {
  static String fromMessage(String? message) {
    final normalized = _normalizeMessage(message ?? '');
    if (normalized.isEmpty) {
      return 'No pudimos completar la operacion. Intenta nuevamente.';
    }

    final upper = normalized.toUpperCase();

    if (upper.contains('INVALID_REFRESH_TOKEN')) {
      return 'Tu sesion expiro. Inicia sesion nuevamente.';
    }
    if (upper.contains('USER NOT AUTHENTICATED')) {
      return 'Necesitas iniciar sesion.';
    }
    if (upper.contains('INVALID AUTHENTICATION TOKEN')) {
      return 'Sesion invalida. Inicia sesion nuevamente.';
    }
    if (upper.contains('ACCESSDENIEDEXCEPTION') ||
        upper.contains('ACCESO DENEGADO') ||
        upper.contains('FORBIDDEN')) {
      return 'No tenes permisos para realizar esta accion.';
    }

    if (upper.contains(
      'CANNOT_CHANGE_TO_NON_COMPETITIVE_WITH_COMPETITIVE_PLAYERS',
    )) {
      return 'No podes cambiar el equipo a recreativo si tiene jugadores competitivos. Revisa la lista de integrantes.';
    }
    if (upper.contains('COMPETITIVE_PLAYER') &&
        upper.contains('NON_COMPETITIVE')) {
      return 'Hay jugadores incompatibles con el tipo de equipo seleccionado. Revisa los integrantes antes de guardar.';
    }
    if (upper.contains('PLAYER_ALREADY_IN_COMPETITIVE_TEAM')) {
      return 'Ese jugador ya pertenece a un equipo competitivo.';
    }
    if (upper.contains('PLAYER_ALREADY_IN_RECREATIVE_TEAM')) {
      return 'Ese jugador ya pertenece a un equipo recreativo.';
    }
    if (upper.contains('TEAM_MEMBERSHIP_TYPE_CONFLICT')) {
      return 'Hay jugadores con conflictos de tipo de equipo (competitivo/recreativo). Revisa los integrantes antes de guardar.';
    }
    if (upper.contains('PLAYERS_ALREADY_IN_TEAM')) {
      return 'Algunos jugadores ya pertenecen a este equipo.';
    }
    if (upper.contains('PERSON_CANNOT_BE_PLAYER_AND_PROFESSOR_IN_SAME_TEAM')) {
      return 'Una misma persona no puede ser jugador y profesor en el mismo equipo.';
    }
    if (upper.contains(
      'PERSON_ALREADY_PROFESSOR_CANNOT_BE_PLAYER_IN_SAME_TEAM',
    )) {
      return 'No podes agregar como jugador a una persona que ya es profesor de este equipo.';
    }
    if (upper.contains(
      'PERSON_ALREADY_PLAYER_CANNOT_BE_PROFESSOR_IN_SAME_TEAM',
    )) {
      return 'No podes agregar como profesor a una persona que ya es jugador de este equipo.';
    }
    if (upper.contains('FIELDUNDEFINED@ATTEMPTUPDATETEAM') ||
        upper.contains('FIELDUNDEFINED@APPLYUPDATETEAM') ||
        upper.contains('UNKNOWNARGUMENT@APPLYUPDATETEAM')) {
      return 'Tu backend no tiene disponible la validacion avanzada de conflictos para equipos. Actualizalo e intenta nuevamente.';
    }

    if (upper.contains('EMAIL NOT REGISTERED')) {
      return 'El email no esta registrado.';
    }
    if (upper.contains('USERNAME OR EMAIL ALREADY EXISTS') ||
        upper.contains('EMAIL_ALREADY_EXISTS')) {
      return 'El email ya esta en uso.';
    }
    if (upper.contains('PERSON_DNI_ALREADY_EXISTS')) {
      return 'El DNI ya esta registrado.';
    }
    if (upper.contains('PERSON_EMAIL_ALREADY_EXISTS')) {
      return 'El email ya esta registrado.';
    }
    if (upper.contains('PERSON_MUST_HAVE_AT_LEAST_ONE_ROLE')) {
      return 'Debes seleccionar al menos un rol.';
    }

    if (upper.contains('PAYMENT_ALREADY_EXISTS_FOR_DUES')) {
      return 'Ya existe un pago para esa cuota.';
    }
    if (upper.contains('PAYMENT_AMOUNT_MUST_BE_POSITIVE')) {
      return 'El monto debe ser mayor a 0.';
    }
    if (upper.contains('PAYMENT_DATE_CANNOT_BE_FUTURE')) {
      return 'La fecha de pago no puede ser futura.';
    }
    if (upper.contains('CANNOT_UPDATE_A_VALIDATE_PAY')) {
      return 'No se puede modificar un pago validado.';
    }
    if (upper.contains('PAYMENT_ALREADY_VALIDATED')) {
      return 'El pago ya esta validado.';
    }

    if (upper.contains('START_DATE_AND_END_DATE_REQUIRED')) {
      return 'Debes indicar fechas de inicio y fin.';
    }
    if (upper.contains('START_DATE_CANNOT_BE_AFTER_END_DATE') ||
        upper.contains('START DATE MUST BE BEFORE OR EQUAL TO END DATE')) {
      return 'La fecha de inicio debe ser anterior o igual a la de fin.';
    }
    if (upper.contains('CANNOT_CREATE_SESSIONS_IN_THE_PAST') ||
        upper.contains('CANNOT_SCHEDULE_SESSION_IN_THE_PAST')) {
      return 'No se pueden crear sesiones en el pasado.';
    }
    if (upper.contains('TRAINING_START_TIME_MUST_BE_BEFORE_END_TIME') ||
        upper.contains('START TIME MUST BE BEFORE END TIME') ||
        upper.contains('END TIME MUST BE AFTER START TIME')) {
      return 'La hora de inicio debe ser anterior a la de fin.';
    }
    if (upper.contains('SESSION_CONFLICT_ON_NEW_DATE') ||
        upper.contains('ANOTHER SESSION ALREADY EXISTS ON THE NEW DATE')) {
      return 'Ya existe una sesion en esa fecha y horario.';
    }

    if (upper.contains('NOTIFICATION_CANNOT_BE_SCHEDULED_IN_THE_PAST')) {
      return 'La notificacion no puede programarse en el pasado.';
    }
    if (upper.contains('NOTIFICATION_MUST_HAVE_RECIPIENTS') ||
        upper.contains('NO_VALID_RECIPIENTS_FOUND')) {
      return 'Debes seleccionar destinatarios validos.';
    }

    if (upper.contains('NOT FOUND') ||
        upper.contains('ENTITYNOTFOUNDEXCEPTION')) {
      return 'No se encontro el recurso solicitado.';
    }

    if (upper.contains('VALIDATION ERROR') ||
        upper.contains('FIELDUNDEFINED@') ||
        upper.contains('UNKNOWNARGUMENT@')) {
      return 'No pudimos procesar la solicitud por una incompatibilidad temporal. Intenta nuevamente en unos segundos.';
    }

    if (normalized.contains('is required') ||
        normalized.contains('is required (@NotBlank)')) {
      return 'Hay campos obligatorios pendientes.';
    }
    if (normalized.contains('format is invalid')) {
      return 'El formato ingresado no es valido.';
    }
    if (normalized.contains('cannot exceed') || normalized.contains('max=')) {
      return 'Algun campo supera el maximo permitido.';
    }
    if (normalized.contains('must be between') || normalized.contains('min=')) {
      return 'Algun campo no cumple el rango permitido.';
    }
    if (normalized.contains('must be positive') ||
        normalized.contains('must be greater than 0')) {
      return 'Algun valor debe ser mayor a 0.';
    }
    if (normalized.contains('must be in the past') ||
        normalized.contains('cannot be in the future')) {
      return 'La fecha ingresada no es valida.';
    }

    if (_looksTechnical(normalized)) {
      return 'No pudimos completar la operacion. Revisa los datos e intenta nuevamente.';
    }

    return normalized;
  }

  static String fromHttpResponse(int statusCode, String body) {
    final messageFromBody = _extractMessage(body);
    if (messageFromBody != null) {
      return fromMessage(messageFromBody);
    }

    switch (statusCode) {
      case 400:
        return 'La solicitud no es valida.';
      case 401:
        return 'Sesion expirada. Inicia sesion nuevamente.';
      case 403:
        return 'No tenes permisos para realizar esta accion.';
      case 404:
        return 'No se encontro el recurso solicitado.';
      case 409:
        return 'La operacion no pudo completarse por un conflicto.';
      case 422:
        return 'Hay datos invalidos. Revisa los campos.';
      default:
        return 'No pudimos completar la operacion. Intenta nuevamente.';
    }
  }

  static String fromException(Object error) {
    return fromMessage(error.toString());
  }

  static bool _looksTechnical(String value) {
    final upper = value.toUpperCase();
    return upper.contains('GRAPHQL') ||
        upper.contains('OPERATIONEXCEPTION') ||
        upper.contains('LINKEXCEPTION') ||
        upper.contains('VALIDATION ERROR') ||
        upper.contains('FIELDUNDEFINED@') ||
        upper.contains('UNKNOWNARGUMENT@') ||
        upper.contains('SUBSELECTIONNOTALLOWED') ||
        upper.contains('SOCKETEXCEPTION') ||
        upper.contains('TYPEMISMATCH') ||
        upper.contains('STACKTRACE') ||
        upper.contains('LOCATIONS:') ||
        upper.contains('EXTENSIONS:') ||
        upper.contains('PATH:') ||
        upper.contains('RESPONSE') ||
        upper.contains('REQUEST');
  }

  static String _normalizeMessage(String value) {
    var result = value.trim();
    if (result.isEmpty) return result;

    result = result
        .replaceAll(RegExp(r'^Exception:\s*', caseSensitive: false), '')
        .replaceAll(
          RegExp(r'^OperationException:\s*', caseSensitive: false),
          '',
        )
        .trim();

    final graphqlMatch = RegExp(
      r'GraphQLError\(message:\s*([^,\)]+)',
      caseSensitive: false,
    ).firstMatch(result);
    if (graphqlMatch != null) {
      return graphqlMatch.group(1)?.trim() ?? result;
    }

    final cannotMatch = RegExp(
      r'(CANNOT_[A-Z_]+)',
      caseSensitive: false,
    ).firstMatch(result);
    if (cannotMatch != null) {
      return cannotMatch.group(1)?.trim() ?? result;
    }

    final playerIdIndex = result.toUpperCase().indexOf('PLAYER ID');
    if (playerIdIndex != -1) {
      return result.substring(0, playerIdIndex).trim();
    }

    return result;
  }

  static String? _extractMessage(String body) {
    if (body.isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message =
            decoded['message'] ?? decoded['error'] ?? decoded['details'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
        if (message is List && message.isNotEmpty) {
          final first = message.first;
          if (first is String && first.trim().isNotEmpty) {
            return first;
          }
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
