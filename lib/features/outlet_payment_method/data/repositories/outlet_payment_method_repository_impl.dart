import 'package:lavendera/core/models/pagination_model.dart';
import 'package:lavendera/features/outlet_payment_method/data/datasources/outlet_payment_method_remote_data_source.dart';
import 'package:lavendera/features/outlet_payment_method/domain/entities/outlet_payment_method.dart';
import 'package:lavendera/features/outlet_payment_method/domain/repositories/outlet_payment_method_repository.dart';

class OutletPaymentMethodRepositoryImpl
    implements OutletPaymentMethodRepository {
  final OutletPaymentMethodRemoteDataSource remoteDataSource;

  OutletPaymentMethodRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OutletPaymentMethod> createOutletPaymentMethod(
    String outletId,
    Map<String, dynamic> body,
  ) async {
    final model = await remoteDataSource.createOutletPaymentMethod(
      outletId,
      body,
    );
    return model.toEntity();
  }

  @override
  Future<PaginatedResult<OutletPaymentMethod>> getOutletPaymentMethods(
    String outletId, {
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final paginatedResult = await remoteDataSource.getOutletPaymentMethods(
      outletId,
      search: search,
      page: page,
      limit: limit,
    );
    return PaginatedResult<OutletPaymentMethod>(
      data: paginatedResult.data.map((m) => m.toEntity()).toList(),
      pagination: paginatedResult.pagination,
    );
  }

  @override
  Future<OutletPaymentMethod> getOutletPaymentMethodById(
    String outletId,
    String paymentMethodId,
  ) async {
    final model = await remoteDataSource.getOutletPaymentMethodById(
      outletId,
      paymentMethodId,
    );
    return model.toEntity();
  }

  @override
  Future<OutletPaymentMethod> updateOutletPaymentMethod(
    String outletId,
    String paymentMethodId,
    Map<String, dynamic> body,
  ) async {
    final model = await remoteDataSource.updateOutletPaymentMethod(
      outletId,
      paymentMethodId,
      body,
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteOutletPaymentMethod(
    String outletId,
    String paymentMethodId,
  ) async {
    return await remoteDataSource.deleteOutletPaymentMethod(
      outletId,
      paymentMethodId,
    );
  }

  @override
  Future<void> uploadQrisImage(
    String outletId,
    String paymentMethodId,
    String filePath,
  ) async {
    return await remoteDataSource.uploadQrisImage(
      outletId,
      paymentMethodId,
      filePath,
    );
  }

  @override
  Future<void> deleteQrisImage(
    String outletId,
    String paymentMethodId,
  ) async {
    return await remoteDataSource.deleteQrisImage(
      outletId,
      paymentMethodId,
    );
  }
}
