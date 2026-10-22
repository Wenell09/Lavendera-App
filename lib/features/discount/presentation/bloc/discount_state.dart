part of 'discount_bloc.dart';

abstract class DiscountState {}

final class DiscountInitial extends DiscountState {}

final class DiscountLoading extends DiscountState {}

final class DiscountPaginationLoading extends DiscountState {
  final List<Discount> discounts;
  final int currentPage;
  final bool hasMorePages;

  DiscountPaginationLoading({
    required this.discounts,
    required this.currentPage,
    required this.hasMorePages,
  });
}

final class DiscountLoaded extends DiscountState {
  final List<Discount> discounts;
  final int currentPage;
  final bool hasMorePages;

  DiscountLoaded({
    required this.discounts,
    required this.currentPage,
    required this.hasMorePages,
  });
}

final class DiscountError extends DiscountState {
  final String message;
  final List<Discount>? cachedDiscounts;

  DiscountError({required this.message, this.cachedDiscounts});
}
