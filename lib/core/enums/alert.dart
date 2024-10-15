enum AlertStyle { regular, danger, success, connection }

enum AlertPosition { top, bottom, connection }

extension NotificationStyleValue on AlertStyle {
  bool get isRegular => this == AlertStyle.regular;

  bool get isDanger => this == AlertStyle.danger;

  bool get isSuccess => this == AlertStyle.success;
}

class Alert {
  final String message;
  final AlertStyle style;
  final AlertPosition position;
  final int hideAfterSec;
  final bool showTimeoutProgress;
  final String? submitText;
  final bool withTopPadding;
  Function? onSubmit;

  Alert(
    this.message, {
    this.style = AlertStyle.regular,
    this.withTopPadding = false,
    this.position = AlertPosition.top,
    this.hideAfterSec = 5,
    this.showTimeoutProgress = false,
    this.submitText,
    this.onSubmit,
  });

  Alert connectionAlert(
          String message, AlertPosition? position, bool? withTopPadding) =>
      Alert(message,
          position: position ?? this.position,
          hideAfterSec: 5,
          withTopPadding: withTopPadding ?? this.withTopPadding);
}
