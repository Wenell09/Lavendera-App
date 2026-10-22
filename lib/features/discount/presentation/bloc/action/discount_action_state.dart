part of 'discount_action_bloc.dart';

abstract class DiscountActionState {}

final class DiscountActionInitial extends DiscountActionState {}

final class DiscountActionLoading extends DiscountActionState {}

final class DiscountActionSuccess extends DiscountActionState {
  final String message;

  DiscountActionSuccess({required this.message});
}

final class DiscountActionError extends DiscountActionState {
  final String message;

  DiscountActionError({required this.message});
}
