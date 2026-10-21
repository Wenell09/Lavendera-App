import '../entities/outlet.dart';
import '../repositories/outlet_repository.dart';

class UpdateOutletUsecase {
  final OutletRepository repository;
  UpdateOutletUsecase(this.repository);
  Future<Outlet> call(String id, Map<String, dynamic> body) async {
    return await repository.updateOutlet(id, body);
  }
}
