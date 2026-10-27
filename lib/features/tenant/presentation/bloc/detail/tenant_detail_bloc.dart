import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/tenant/domain/entities/tenant.dart';
import 'package:lavendera/features/tenant/domain/usecases/get_tenant_usecase.dart';

part 'tenant_detail_event.dart';
part 'tenant_detail_state.dart';

class TenantDetailBloc extends Bloc<TenantDetailEvent, TenantDetailState> {
  final GetTenantUsecase _getTenantUsecase;

  TenantDetailBloc({required this._getTenantUsecase})
      : super(TenantDetailInitial()) {
    on<GetTenantRequest>((event, emit) async {
      emit(TenantDetailLoading());
      try {
        final tenant = await _getTenantUsecase.call(event.id);
        emit(TenantDetailLoaded(tenant: tenant));
      } on ApiException catch (e) {
        emit(TenantDetailError(message: e.message));
      } catch (e) {
        emit(TenantDetailError(message: 'Gagal memuat informasi tenant'));
      }
    });
  }
}
