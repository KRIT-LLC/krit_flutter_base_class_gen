import 'dart:async';

class Failure<T> extends Result<T> {
  @override
  final String? message;
  final Exception? exception;

  Failure({this.exception, this.message});
}

class Success<T> extends Result<T> {
  final T data;

  @override
  final String? message;

  Success(this.data, {this.message});
}

class EmptyResult<T> extends Result<T> {}

class ResultNotificationClose<T> extends Result<T> {}

abstract class Result<T> {
  String? message;

  Result doOnSuccess(Function(T value) callback) {
    Result result = this;
    if (result is Success) {
      callback(result.data);
    }
    return result;
  }

  Result doOnError(Function(String? message, Exception? exception) callback) {
    Result result = this;
    if (result is Failure) {
      callback(result.message, result.exception);
    }
    return result;
  }

  Future<Result> doFutureOnSuccess(
      Future<Result> Function(Result value) callback) async {
    Result result = this;
    if (result is Success) {
      await callback(result.data);
    }
    return result;
  }
}
