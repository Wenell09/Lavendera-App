import 'package:lavendera/features/outlet_user/data/models/outlet_summary_model.dart';
import 'package:lavendera/features/outlet_user/data/models/user_summary_model.dart';
import 'package:lavendera/features/outlet_user/domain/entities/user_with_outlets.dart';

class UserWithOutletsModel extends UserWithOutlets {
  UserWithOutletsModel({
    required super.user,
    required super.outlets,
  });

  factory UserWithOutletsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final userJson = data['user'] ?? {};
    final outletsJson = data['outlets'] as List? ?? [];

    return UserWithOutletsModel(
      user: UserSummaryModel.fromJson(userJson),
      outlets: outletsJson.map((e) => OutletSummaryModel.fromJson(e)).toList(),
    );
  }
}
