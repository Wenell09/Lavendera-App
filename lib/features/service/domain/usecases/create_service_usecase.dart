import '../entities/service_item.dart';
import '../repositories/service_repository.dart';

class CreateServiceUsecase {
  final ServiceRepository repository;

  CreateServiceUsecase(this.repository);

  Future<LaundryService> call(Map<String, dynamic> body) async {
    return await repository.createService(body);
  }
}
