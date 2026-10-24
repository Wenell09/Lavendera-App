import 'package:lavendera/core/models/pagination_model.dart';
import 'package:lavendera/features/outlet_user/data/models/outlet_summary_model.dart';
import 'package:lavendera/features/outlet_user/data/models/user_summary_model.dart';
import 'package:lavendera/features/outlet_user/domain/entities/outlet_with_users.dart';

class OutletWithUsersModel extends OutletWithUsers {
  OutletWithUsersModel({
    required super.outlet,
    required super.users,
    super.pagination,
  });

  factory OutletWithUsersModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final outletJson = data['outlet'] ?? {};
    final usersJson = data['users'] as List? ?? [];
    final meta = json['meta'] ?? {};
    final paginationJson = meta['pagination'];

    return OutletWithUsersModel(
      outlet: OutletSummaryModel.fromJson(outletJson),
      users: usersJson.map((e) => UserSummaryModel.fromJson(e)).toList(),
      pagination: paginationJson != null ? Pagination.fromJson(paginationJson) : null,
    );
  }
}
