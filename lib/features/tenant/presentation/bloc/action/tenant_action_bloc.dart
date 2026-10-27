import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/tenant/domain/entities/tenant.dart';
import 'package:lavendera/features/tenant/domain/usecases/update_tenant_usecase.dart';

part 'tenant_action_event.dart';
part 'tenant_action_state.dart';

class TenantActionBloc extends Bloc<TenantActionEvent, TenantActionState> {
  final UpdateTenantUsecase _updateTenantUsecase;

  TenantActionBloc({required this._updateTenantUsecase})
      : super(TenantActionInitial()) {
    on<UpdateTenantActionRequest>((event, emit) async {
      emit(TenantActionLoading());
      try {
        final tenant = await _updateTenantUsecase.call(event.id, event.body);
        emit(TenantActionSuccess(
          message: 'Tenant berhasil diperbarui',
          tenant: tenant,
        ));
      } on ApiException catch (e) {
        emit(TenantActionError(message: e.message));
      } catch (e) {
        emit(TenantActionError(message: 'Gagal memperbarui tenant'));
      }
    });
  }
}
