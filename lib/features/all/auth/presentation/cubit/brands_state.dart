part of 'brands_cubit.dart';

sealed class BrandsState extends Equatable {
  const BrandsState();

  @override
  List<Object> get props => [];
}

final class BrandsInitial extends BrandsState {}

final class BrandsLoading extends BrandsState {}

final class BrandsSuccess extends BrandsState {
  final List<Brand> brands;

  const BrandsSuccess(this.brands);

  @override
  List<Object> get props => [brands];
}

final class BrandsError extends BrandsState {
  final String message;

  const BrandsError(this.message);

  @override
  List<Object> get props => [message];
}
