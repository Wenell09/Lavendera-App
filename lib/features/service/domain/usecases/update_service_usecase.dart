import '../entities/service_item.dart';
import '../repositories/service_repository.dart';

class UpdateServiceUsecase {
  final ServiceRepository repository;

  UpdateServiceUsecase(this.repository);

  Future<LaundryService> call(String id, Map<String, dynamic> body) async {
    return await repository.updateService(id, body);
  }
}
