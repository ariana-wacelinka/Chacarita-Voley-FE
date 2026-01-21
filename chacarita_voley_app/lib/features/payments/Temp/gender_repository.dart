// import '../../domain/entities/gender.dart';
// import '../../domain/repositories/gender_repository_interface.dart';
import 'gender.dart';
import 'gender_repository_interface.dart';

class GenderRepository implements GenderRepositoryInterface {
  @override
  List<Gender> getGenders() {
    return Gender.values;
  }
}
