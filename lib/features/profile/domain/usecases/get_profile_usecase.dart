import 'package:lavendera/features/profile/domain/entities/profile.dart';
import 'package:lavendera/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUsecase {
  final ProfileRepository repository;

  GetProfileUsecase(this.repository);

  Future<Profile> call() async {
    return await repository.getProfile();
  }
}
