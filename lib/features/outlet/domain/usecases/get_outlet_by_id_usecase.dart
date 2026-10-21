import '../entities/outlet.dart';
import '../repositories/outlet_repository.dart';

class GetOutletByIdUsecase {
  final OutletRepository repository;
  GetOutletByIdUsecase(this.repository);
  Future<Outlet> call(String id) async {
    return await repository.getOutletById(id);
  }
}
