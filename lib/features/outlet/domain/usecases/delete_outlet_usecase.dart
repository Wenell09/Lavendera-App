import '../repositories/outlet_repository.dart';

class DeleteOutletUsecase {
  final OutletRepository repository;
  DeleteOutletUsecase(this.repository);
  Future<void> call(String id) async {
    return await repository.deleteOutlet(id);
  }
}
