import 'package:lavendera/features/outlet_user/data/models/outlet_summary_model.dart';
import 'package:lavendera/features/outlet_user/data/models/user_summary_model.dart';
import 'package:lavendera/features/outlet_user/domain/entities/user_with_outlet.dart';

class UserWithOutletsModel extends UserWithOutlet {
  UserWithOutletsModel({required super.user, required super.outlet});

  factory UserWithOutletsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final userJson = data['user'] ?? {};
    final outletsJson = data['outlet'] ?? {};

    return UserWithOutletsModel(
      user: UserSummaryModel.fromJson(userJson),
      outlet: OutletSummaryModel.fromJson(outletsJson),
    );
  }
}
