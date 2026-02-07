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
    final input = {'date': date, 'amount': amount, 'state': state};

    if (fileName != null) {
      input['fileName'] = fileName;
    }

    if (fileUrl != null) {
      input['fileUrl'] = fileUrl;
    }

    return {'dueId': dueId, 'input': input};
  }
}
