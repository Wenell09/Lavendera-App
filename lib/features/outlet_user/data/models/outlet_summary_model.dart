import 'package:lavendera/features/outlet_user/domain/entities/outlet_summary.dart';

class OutletSummaryModel extends OutletSummary {
  OutletSummaryModel({
    required super.id,
    required super.name,
    required super.slug,
  });

  factory OutletSummaryModel.fromJson(Map<String, dynamic> json) {
    return OutletSummaryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
    };
  }
}
