class CreatePayInput {
  final String dueId; // ID del currentDue del jugador
  final String? fileName;
  final String? fileUrl;
  final String date; // Requerido
  final double amount;
  final String? state; // enum

  const CreatePayInput({
    required this.dueId,
    this.fileName,
    this.fileUrl,
    required this.date,
    required this.amount,
    this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      'dueId': dueId,
      'input': {
        'fileName': fileName,
        'fileUrl': fileUrl,
        'date': date,
        'amount': amount,
        'state': state,
      },
    };
  }
}
