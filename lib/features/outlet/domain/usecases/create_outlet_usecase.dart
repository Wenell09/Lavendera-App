import '../entities/outlet.dart';
import '../repositories/outlet_repository.dart';

class CreateOutletUsecase {
  final OutletRepository repository;
  CreateOutletUsecase(this.repository);
  Future<Outlet> call(Map<String, dynamic> body) async {
    return await repository.createOutlet(body);
  }
}
