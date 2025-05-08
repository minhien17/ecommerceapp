// import 'dart:convert';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:path_provider/path_provider.dart';


// class ApiInterceptors extends InterceptorsWrapper {
//   @override
//   void onRequest(
//       RequestOptions options, RequestInterceptorHandler handler) async {
//     final method = options.method;
//     final uri = options.uri;
//     final data = options.data;
//     // options.persistentConnection = false;
//     // final authRepository = Get.find<AuthRepository>(tag: (AuthRepository).toString());

//     apiLogger.log(
//         "\n\n--------------------------------------------------------------------------------------------------------");
//     if (method == 'GET') {
//       apiLogger.log(
//           "✈️ REQUEST[$method] => PATH: $uri \n Token: ${options.headers}",
//           printFullText: true);
//       writeLogToFile("✈️ REQUEST[$method] => PATH: $uri}");
//     } else {
//       try {
//         apiLogger.log(
//             "✈️ REQUEST[$method] => PATH: $uri \n DATA: ${jsonEncode(data)}",
//             printFullText: true);
//         writeLogToFile(
//             "✈️ REQUEST[$method] => PATH: $uri \n DATA: ${jsonEncode(data)}");
//       } catch (e) {
//         apiLogger.log("✈️ REQUEST[$method] => PATH: $uri \n DATA: $data",
//             printFullText: true);
//         writeLogToFile("✈️ REQUEST[$method] => PATH: $uri \n DATA: $data");
//       }
//     }

//     super.onRequest(options, handler);
//   }

//   void writeLogToFile(String log) async {
//     if (ApiUtil.getInstance()?.IS_SHOW_LOG ?? false) {
//       final directory = Platform.isAndroid
//           ? Directory("/storage/emulated/0/Documents") //FOR ANDROID
//           : await getApplicationDocumentsDirectory(); //FOR iOS
//       final file = File('${directory.path}/logBitel.txt');
//       await file.writeAsString('$log\n', mode: FileMode.append);
//     }
//   }

//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) {
//     final statusCode = response.statusCode;
//     final uri = response.requestOptions.uri;
//     final data = jsonEncode(response.data);
//     apiLogger.log("✅ RESPONSE[$statusCode] => PATH: $uri\n DATA: $data");
//     writeLogToFile("✅ RESPONSE[$statusCode] => PATH: $uri\n DATA: $data");
//     //Handle section expired
//     if (response.statusCode == 401) {
//       // final authRepository = Get.find<AuthRepository>(tag: (AuthRepository).toString());
//       // authRepository.signOut();
//       // Get.off(SignInPage());
//     }
//     super.onResponse(response, handler);
//   }

//   @override
//   void onError(DioError err, ErrorInterceptorHandler handler) {
//     final statusCode = err.response?.statusCode;
//     final uri = err.requestOptions.path;
//     var data = "";
//     try {
//       data = jsonEncode(err.response?.data);
//     } catch (e) {}
//     apiLogger.log("⚠️ ERROR[$statusCode] => PATH: $uri\n DATA: $data");
//     writeLogToFile("⚠️ ERROR[$statusCode] => PATH: $uri\n DATA: $data");
//     super.onError(err, handler);
//   }
// }

// class RetryOnConnectionChangeInterceptor extends Interceptor {
//   final Dio dio;
//   final int maxRetries = 2;
//   int retryCount = 0;
//   RetryOnConnectionChangeInterceptor({
//     required this.dio,
//   });

//   @override
//   void onError(DioError err, ErrorInterceptorHandler handler) async {
//     if (_shouldRetryOnHttpException(err)) {
//       try {
//         await dio
//             .fetch<void>(err.requestOptions)
//             .then((value) => handler.resolve(value));
//       } on DioError catch (e) {
//         super.onError(e, handler);
//       }
//     } else {
//       super.onError(err, handler);
//     }
//   }

//   bool _shouldRetryOnHttpException(DioError err) {
//     retryCount++;

//     var rs = (retryCount < maxRetries) &&
//         err.type == DioErrorType.unknown &&
//         ((err.error is HttpException &&
//             (err.message ?? "").contains(
//                 'Connection closed before full header was received')));
//     if (!rs) {
//       retryCount = 0;
//     }

//     return rs;
//   }
// }
