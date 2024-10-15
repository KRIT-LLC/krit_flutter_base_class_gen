import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';

import '../../core/enums/alert.dart';
import '../../core/enums/loading_state.dart';
import 'package:base_class_gen/core/result_of.dart';
import 'package:base_class_gen/domain/base_use_case.dart';

class BaseViewModel extends ChangeNotifier {
  BaseViewModel({this.blockUI});

  final Function(bool)? blockUI;
  LoadingState _loadingState = LoadingState.initial;

  List<Alert> alerts = [];
  bool _disposed = false;
  bool hasLoadError = false;
  bool hasInternet = true;

  Result currentResult = EmptyResult();
  Timer? _timerNotification;

  String get title => '';

  LoadingState get currentLoadingState => _loadingState;

  Future<Result<T>> executeUseCaseParam<T, Y>(BaseUseCase useCase, Y param,
      {bool showLoading = false, bool cancelLoading = false}) async {
    if (showLoading) loadingOn();
    if (useCase is UseCaseParam<Result<T>, Y>) {
      Result<T> result;
      if (param != null) {
        result = await useCase(param);
        result.doOnError((message, exception) {
          hasLoadError = true;
          addErrorAlert(message: message);
        }).doOnSuccess((value) {
          hasLoadError = false;
        });
        loadingOff();
        return result;
      } else {
        loadingOff();
        return Failure(message: 'param is null');
      }
    } else if (useCase is UseCaseNameParam<Result<T>, Y>) {
      Result<T> result;
      if (param != null) {
        result = await useCase(param: param);
        result.doOnError((message, exception) {
          hasLoadError = true;
          addErrorAlert(message: message);
        }).doOnSuccess((value) {
          hasLoadError = false;
          loadingOff();
        });
        loadingOff();
        return result;
      } else {
        loadingOff();
        return Failure(message: 'param is null');
      }
    } else {
      loadingOff();
      return Failure(message: 'unknown use case');
    }
  }

  Future<Result<T>> executeUseCase<T>(BaseUseCase useCase,
      {bool showLoading = false, bool cancelLoading = false}) async {
    if (showLoading) loadingOn();
    if (useCase is UseCase<Result<T>>) {
      var result = await useCase();
      result.doOnError((message, exception) {
        hasLoadError = true;
        addErrorAlert(message: message);
      }).doOnSuccess((value) {
        hasLoadError = false;
        hasInternet = true;
      });

      loadingOff();
      return result;
    } else {
      loadingOff();
      return Failure(message: 'unknown use case');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timerNotification?.cancel();
    _timerNotification = null;
    super.dispose();
  }

  void addAlert(Alert alert) {
    var appendedAlert = alert.message == 'network error'
        ? alert.connectionAlert(
            alert.message, AlertPosition.connection, alert.withTopPadding)
        : alert;
    alerts.add(appendedAlert);
    notifyListeners();
    if (appendedAlert.onSubmit != null) {
      final onSubmit = appendedAlert.onSubmit;
      appendedAlert.onSubmit = () {
        onSubmit?.call();
        alerts.remove(appendedAlert);
      };
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
    _timerNotification = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick == appendedAlert.hideAfterSec && !_disposed) {
        log('remove alert');
        timer.cancel();
        alerts.remove(appendedAlert);
        notifyListeners();
      }
    });
  }

  void clearAlerts() {
    log('clear alerts call');
    alerts.clear();
    _timerNotification?.cancel();
    _timerNotification = null;
    notifyListeners();
  }

  void loadingOn() {
    _loadingState = LoadingState.loading;
    if (blockUI != null) blockUI!(true);
    log('loading start');
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  void loadingOff() {
    _loadingState = LoadingState.initial;
    if (blockUI != null) blockUI!(false);
    log('loading finish');
    notifyListeners();
  }

  void addErrorAlert({String? message}) {
    addAlert(Alert(message ?? '',
        style: AlertStyle.danger,
        hideAfterSec: 5,
        position: AlertPosition.top));
  }

  void addConnectionAlert({String? message}) {
    addAlert(Alert(message ?? 'Unhandled error',
        style: AlertStyle.connection,
        hideAfterSec: 10,
        onSubmit: () => clearAlerts(),
        position: AlertPosition.connection,
        withTopPadding: true));
  }
}
