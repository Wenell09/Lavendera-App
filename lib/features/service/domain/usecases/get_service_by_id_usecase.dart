import '../entities/service_item.dart';
import '../repositories/service_repository.dart';

class GetServiceByIdUsecase {
  final ServiceRepository repository;

  GetServiceByIdUsecase(this.repository);

  Future<LaundryService> call(String id) async {
    return await repository.getServiceById(id);
  }
}
