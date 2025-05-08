import 'package:dio/dio.dart';

class ApiUtil {
  bool IS_SHOW_LOG = false;
  Dio? dio;
  static ApiUtil? _mInstance;
  CancelToken cancelToken = CancelToken();

  static ApiUtil? getInstance() {
    _mInstance ??= ApiUtil();
    return _mInstance;
  }

  ApiUtil() {
    if (dio == null) {
      dio = Dio();
      dio!.options.connectTimeout = const Duration(seconds: 60);
      dio!.options.receiveTimeout = const Duration(seconds: 60);
      // dio!.options.headers = {
      //     "Accept-language": "en",
      //     "device-type": DeviceUtils.getPlatform(),
      //     "app-revision": 123,
      //     "app-version": DeviceUtils.getVersion(),
      //     "push-id": "",
      //     "app-provision": DeviceUtils.getPackageName(),
      //     "os-version": DeviceUtils.getOSVersion(),
      //     "device-name": DeviceUtils.getDeviceName()
      // };
      // dio!.options.persistentConnection = false;
      // dio!.interceptors.add(ApiInterceptors(dio!));
      // dio!.interceptors.add(RetryOnConnectionChangeInterceptor(dio: dio!));
    }
  }

  Future<BaseResponse> get({
    required String url,
    Map<String, dynamic> params = const {},
    String contentType = Headers.jsonContentType,
  }) async {
    try {
      var response = await dio!.get(url,
          queryParameters: params,
          options: Options(
            persistentConnection: false,
            contentType: contentType,
          ),
          cancelToken: cancelToken);
      return getBaseResponse(response);
    } catch (error) {
      return BaseResponse.error(error.toString());
    }
  }

  Future<BaseResponse> post({
    required String url,
    Map<String, dynamic>? body,
    Map<String, dynamic> params = const {},
    String contentType = Headers.jsonContentType,
  }) async {
    try {
      var response = await dio!.post(url,
          queryParameters: params,
          data: body,
          options: Options(
            responseType: ResponseType.json,
            contentType: contentType,
            persistentConnection: false,
          ),
          cancelToken: cancelToken);
      return getBaseResponse(response);
    } catch (error) {
      return BaseResponse.error(error.toString());
    }
  }

  Future<BaseResponse> uploadFile(
      {required String url,
      required FormData data,
      Map<String, dynamic> params = const {},
      String contentType = Headers.multipartFormDataContentType}) async {
    try {
      var response = await dio!.post(url,
          queryParameters: params,
          data: data,
          options: Options(
            responseType: ResponseType.json,
            contentType: contentType,
            persistentConnection: false,
          ), onSendProgress: (sent, total) {
        print("Đã gửi: $sent / $total");
      }, cancelToken: cancelToken);
      return getBaseResponse(response);
    } catch (error) {
      return BaseResponse.error(error.toString());
    }
  }

  void postDetectImage({
    required String url,
    Map<String, dynamic>? body,
    Map<String, dynamic> params = const {},
    bool isDetect = false,
    String contentType = Headers.jsonContentType,
    required Function(BaseResponse response) onSuccess,
    required Function(dynamic error) onError,
  }) async {
    dio!.options.headers['Authorization'] = '';
    dio!
        .post(url,
            queryParameters: params,
            data: body,
            options: Options(
              responseType: ResponseType.json,
              contentType: contentType,
              persistentConnection: false,
            ),
            cancelToken: cancelToken)
        .then((res) {
      if (onSuccess != null) onSuccess(getBaseResponse(res));
    }).catchError((error) {
      if (onError != null) onError(error);
    });
  }

  void postFileDebt({
    required String url,
    required String path,
    Map<String, dynamic> params = const {},
    bool isDetect = false,
    String contentType = Headers.jsonContentType,
    required Function(BaseResponse response) onSuccess,
    required Function(dynamic error) onError,
  }) async {
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(path),
    });
    // String token = await SharedPreferenceUtil.getToken();
    // if (!isDetect) {
    //   if (token.isNotEmpty) {
    //     dio!.options.headers['Authorization'] = 'Bearer ${token}';
    //   }
    // } else {
    //   dio!.options.headers['Authorization'] =
    //       'Bearer AIzaSyDyzsELhb6aZYiMPL5NB3AZj8m7HUVFogo';
    // }
    dio!
        .post(url,
            queryParameters: params,
            data: formData,
            options: Options(
              responseType: ResponseType.json,
              contentType: contentType,
              persistentConnection: false,
            ),
            cancelToken: cancelToken)
        .then((res) {
      if (onSuccess != null) onSuccess(getBaseResponse(res));
    }).catchError((error) {
      if (onError != null) onError(error);
    });
  }

  void delete(
      {required String url,
      Map<String, dynamic> params = const {},
      required Function(BaseResponse response) onSuccess,
      required Function(dynamic error) onError,
      bool isCancel = false}) async {
    // String token = await SharedPreferenceUtil.getToken();
    // if (token.isNotEmpty) {
    //   dio!.options.headers['Authorization'] = 'Bearer ${token}';
    // }
    // if(isCancel) {
    //   dio!.options.
    // }
    dio!
        .delete(url, queryParameters: params, cancelToken: cancelToken)
        .then((res) {
      if (onSuccess != null) onSuccess(getBaseResponse(res));
    }).catchError((error) {
      onError(error);
    });
  }

  BaseResponse getBaseResponse(Response response) {
    return BaseResponse.success(
        data: response.data ?? "",
        code: response.statusCode,
        message: response.statusMessage,
        status: response.data['status']);
  }
}

class BaseResponse {
  String? message;
  int? code;
  dynamic data;
  int? status;
  String? errMessage;

  BaseResponse.success(
      {this.data, this.code, this.message, this.status, this.errMessage});

  BaseResponse.error(this.message, {this.data, this.code});

  bool get isSuccess => code != null && code == 200;
  bool get isStatusSuccess => status == 200;
}
