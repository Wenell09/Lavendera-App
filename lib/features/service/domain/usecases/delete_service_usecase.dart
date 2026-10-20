import '../repositories/service_repository.dart';

class DeleteServiceUsecase {
  final ServiceRepository repository;

  DeleteServiceUsecase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteService(id);
  }
}
