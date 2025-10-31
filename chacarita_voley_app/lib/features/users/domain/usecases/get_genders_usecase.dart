import '../entities/gender.dart';
import '../repositories/gender_repository_interface.dart';

class GetGendersUseCase {
  final GenderRepositoryInterface repository;

  GetGendersUseCase(this.repository);

  List<Gender> execute() {
    return repository.getGenders();
  }
}