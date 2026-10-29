import 'package:lavendera/features/outlet_user/domain/entities/outlet_summary.dart';
import 'package:lavendera/features/outlet_user/domain/entities/user_summary.dart';

class UserWithOutlet {
  final UserSummary user;
  final OutletSummary outlet;

  UserWithOutlet({required this.user, required this.outlet});
}
