import 'package:lavendera/core/models/pagination_model.dart';
import 'package:lavendera/features/outlet_user/domain/entities/outlet_summary.dart';
import 'package:lavendera/features/outlet_user/domain/entities/user_summary.dart';

class OutletWithUsers {
  final OutletSummary outlet;
  final List<UserSummary> users;
  final Pagination? pagination;

  OutletWithUsers({
    required this.outlet,
    required this.users,
    this.pagination,
  });
}
