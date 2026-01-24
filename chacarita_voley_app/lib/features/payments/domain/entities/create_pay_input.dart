class CreatePayInput {
  final String? fileName;
  final String? fileUrl;
  final String date; // Requerido? //TODO
  final String time;
  final double amount;
  final String? state; // enum

  const CreatePayInput({
    this.fileName,
    this.fileUrl,
    required this.date,
    required this.time,
    required this.amount,
    this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'fileUrl': fileUrl,
      'date': date,
      'time': time,
      'amount': amount,
      'state': state,
    };
  }
}
