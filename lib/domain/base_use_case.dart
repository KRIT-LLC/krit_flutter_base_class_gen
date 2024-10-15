import 'package:base_class_gen/core/result_of.dart';

abstract class BaseUseCase {}

abstract class UseCase<T extends Result> extends BaseUseCase {
  Future<T> call();
}

abstract class UseCaseParam<T extends Result, R> extends BaseUseCase {
  Future<T> call(R param);
}

abstract class UseCaseNameParam<T extends Result, R> extends BaseUseCase {
  Future<T> call({R param});
}
