import '../entities/training.dart';

abstract class TrainingRepositoryInterface {
  Future<List<Training>> getTrainings({
    DateTime? startDate,
    DateTime? endDate,
    String? teamId,
    TrainingStatus? status,
  });

  Future<Training?> getTrainingById(String id);

  Future<Training> createTraining(Training training);

  Future<Training> updateTraining(Training training);

  Future<void> deleteTraining(String id);

  Future<Training> updateAttendance(
    String trainingId,
    List<PlayerAttendance> attendances,
  );
}
