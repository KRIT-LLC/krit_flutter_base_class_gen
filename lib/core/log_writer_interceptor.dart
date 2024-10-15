import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:base_class_gen/presentation/dimen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LogWriterInterceptor extends Interceptor {
  LogWriterInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    var params = options.queryParameters.toString();
    var responseType = options.responseType;
    var method = options.method;
    var data = options.data;
    var headers = options.headers;
    log('HEADERS $headers');
    log('\n${DateTime.now()}\nREQUEST-NAME: ${options.path} \nPARAMS: $params \nMETHOD-RESPONSE TYPE: $method - $responseType \nDATA: $data\nBASE_URL: ${options.baseUrl}');
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('\nERROR-MESSAGE: ${err.message}\n ERROR: ${err.error} \n ERROR-TYPE: ${err.type}');
    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('\nRESPONSE-DATA: ${jsonEncode(response.data)}\n STATUS-MESSAGE: ${response.statusMessage}');
    handler.next(response);
  }
}

Future<void> readLog({BuildContext? context}) async {
  final logFilename = DateTime.now().toString().split(' ').first;
  final logPath = await getApplicationDocumentsDirectory();
  final logFile = File('${logPath.path}/$logFilename-log.txt');
  final newPath = Platform.isAndroid
      ? await getExternalStorageDirectory()
      : await getApplicationDocumentsDirectory();
  if (newPath != null) {
    var file = File('${newPath.path}/$logFilename-log.txt')
      ..createSync(recursive: true);
    await file.writeAsBytes(logFile.readAsBytesSync());
  }
  if (context != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.grey,
        content: Center(
            child: Container(
                padding: const EdgeInsets.all(Dimen.size12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimen.size12)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('log file saved to path: ',
                          style: TextStyle(color: Colors.white)),
                      const SizedBox(height: Dimen.size8),
                      Text(newPath?.path ?? '',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600))
                    ])))));
  }
}

Future<void> log(String message,
    {Object? e, bool needWrite = false, bool needPrint = false}) async {
  final logFilename = DateTime.now().toString().split(' ').first;
  if (needPrint) dev.log(message.replaceAll('\\', ''), error: e);
  if (!needWrite) return;
  final logPath = await getApplicationDocumentsDirectory();
  final logFile = File('${logPath.path}/$logFilename-log.txt');
  logFile.writeAsString('\n${message.replaceAll('\\', '')}',
      mode: FileMode.writeOnlyAppend);
  if (e != null) {
    logFile.writeAsString('\n $e');
  }
}
