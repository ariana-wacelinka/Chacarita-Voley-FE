class UpdatePayInput {
  final String id; // Requerido para update
  final String? fileName;
  final String? fileUrl;
  final String? date;
  final String? time;
  final double? amount;
  final String? state;

  const UpdatePayInput({
    required this.id,
    this.fileName,
    this.fileUrl,
    this.date,
    this.time,
    this.amount,
    this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (fileName != null) 'fileName': fileName,
      if (fileUrl != null) 'fileUrl': fileUrl,
      if (date != null) 'date': date,
      if (time != null) 'time': time,
      if (amount != null) 'amount': amount,
      if (state != null) 'state': state,
    };
  }
}
