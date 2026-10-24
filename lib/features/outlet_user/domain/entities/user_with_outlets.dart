import 'package:lavendera/features/outlet_user/domain/entities/outlet_summary.dart';
import 'package:lavendera/features/outlet_user/domain/entities/user_summary.dart';

class UserWithOutlets {
  final UserSummary user;
  final List<OutletSummary> outlets;

  UserWithOutlets({
    required this.user,
    required this.outlets,
  });
}
