import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:common/models/gallery_category.dart';
import 'package:common/models/gallery_image.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/requests.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/device_info.dart';
import 'package:common/utils/preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:pretty_json/pretty_json.dart';

//顶层变量
Network network = Network._internal();

enum HttpMethod { get, post, put, delete }

class Network {
  /// 顶层变量，单例模式
  Network._internal() {
    _prepareHttpClient();
  }

  // static const host = "api.fygtapp.cn";
  static const host = "stgapi.hooh.zone";

  // static const serverPathPrefix = "v2/";
  static const serverPathPrefix = "";

  late final http.Client _client;
  bool _isUsingLocalServer = false;

  void requestAsync<T>(Future<T> request, Function(T data) onSuccess, Function(HoohApiErrorResponse error) onError) {
    request.then(onSuccess).catchError((error) {
      if (error is HoohApiErrorResponse) {
        onError(error);
      }
    });
  }

  void setUserToken(String token) {
    preferences.putString(Preferences.keyUserAccessToken, token);
  }

  String getS3ImageKey(String? url) {
    if (url == null) {
      return "";
    }
    if (url.contains("?") && url.contains("com/")) {
      return url.substring(url.indexOf("com/") + "com/".length, url.indexOf("?"));
    }
    return url;
  }

  // Future<ValidateCodeResponse> requestValidationCodeForRegister(int countryCode, String mobile) {
  //   return _getResponseObject<ValidateCodeResponse>(HttpMethod.post, _buildHoohUri("users/register/request-validation-code"),
  //       body: ValidateMobileRequest(countryCode, mobile).toJson(), deserializer: ValidateCodeResponse.fromJson);
  // }
  //
  // Future<ValidateAccountResponse> validationCodeForRegister(int countryCode, String mobile, String code) {
  //   return _getResponseObject<ValidateAccountResponse>(HttpMethod.post, _buildHoohUri("users/register/validate"),
  //       body: ValidateAccountRequest(countryCode, mobile, code).toJson(), deserializer: ValidateAccountResponse.fromJson);
  // }
  //
  // Future<LoginResponse> register(String token, String password) {
  //   String encryptedPassword = sha512.convert(utf8.encode(password)).toString();
  //   return _getResponseObject<LoginResponse>(HttpMethod.post, _buildHoohUri("users/register"),
  //       body: RegisterRequest(token, encryptedPassword).toJson(), deserializer: LoginResponse.fromJson);
  // }
  Future<LoginResponse> register(String username, String password, String email) {
    String encryptedPassword = sha512.convert(utf8.encode(password)).toString();
    return _getResponseObject<LoginResponse>(HttpMethod.post, _buildHoohUri("users/register"),
        body: RegisterRequest(username, email, encryptedPassword).toJson(), deserializer: LoginResponse.fromJson);
  }

  Future<LoginResponse> login(String username, String password) {
    String encryptedPassword = sha512.convert(utf8.encode(password)).toString();
    return _getResponseObject<LoginResponse>(HttpMethod.post, _buildHoohUri("users/login"),
        body: LoginWithPasswordRequest(username, encryptedPassword).toJson(), deserializer: LoginResponse.fromJson);
  }

  Future<RequestValidationCodeResponse> resetPasswordRequestValidationCode(String target, int type) {
    assert([RequestValidationCodeResponse.typeEmail, RequestValidationCodeResponse.typeMobile].contains(type));
    return _getResponseObject<RequestValidationCodeResponse>(HttpMethod.post, _buildHoohUri("users/reset-password/request-validation-code"),
        body: RequestValidationCodeRequest(type, target).toJson(), deserializer: RequestValidationCodeResponse.fromJson);
  }

  Future<ValidateCodeResponse> resetPasswordValidateCode(String target, String code) {
    return _getResponseObject<ValidateCodeResponse>(HttpMethod.post, _buildHoohUri("users/reset-password/validate"),
        body: ValidateCodeRequest(target, code).toJson(), deserializer: ValidateCodeResponse.fromJson);
  }

  Future<void> resetPassword(String token, String password) {
    String encryptedPassword = sha512.convert(utf8.encode(password)).toString().toLowerCase();
    return _getResponseObject<void>(HttpMethod.post, _buildHoohUri("users/reset-password"), body: ResetPasswordRequest(token, encryptedPassword).toJson());
  }

  Future<RequestValidationCodeResponse> bindAccountRequestValidationCode(String target, int type) {
    assert([RequestValidationCodeResponse.typeEmail, RequestValidationCodeResponse.typeMobile].contains(type));
    return _getResponseObject<RequestValidationCodeResponse>(HttpMethod.post, _buildHoohUri("users/binding/request-validation-code"),
        body: RequestValidationCodeRequest(type, target).toJson(), deserializer: RequestValidationCodeResponse.fromJson);
  }

  Future<ValidateCodeResponse> bindAccountValidateCode(String target, String code) {
    return _getResponseObject<ValidateCodeResponse>(HttpMethod.post, _buildHoohUri("users/binding/validate"),
        body: ValidateCodeRequest(target, code).toJson(), deserializer: ValidateCodeResponse.fromJson);
  }

  Future<User> getUserInfo(String userId) {
    return _getResponseObject<User>(HttpMethod.get, _buildHoohUri("users/$userId"), deserializer: User.fromJson);
  }

  Future<User> changeUserInfo(String userId, {String? name, String? signature, String? website, String? avatarKey}) {
    return _getResponseObject<User>(HttpMethod.put, _buildHoohUri("users/$userId"),
        body: ChangeUserInfoRequest(
          name: name,
          signature: signature,
          website: website,
          avatarKey: avatarKey,
        ).toJson(),
        deserializer: User.fromJson);
  }

  Future<RequestUploadingFileResponse> requestUploadingAvatar(String userId, File file) {
    String fileMd5 = md5.convert(file.readAsBytesSync()).toString().toLowerCase();
    String ext = file.path;
    debugPrint("upload file md5=$fileMd5 path=$ext");
    ext = ext.substring(ext.lastIndexOf(".") + 1);
    return _getResponseObject<RequestUploadingFileResponse>(HttpMethod.post, _buildHoohUri("users/$userId/request-uploading-avatar"),
        body: RequestUploadingFileRequest(fileMd5, ext).toJson(), deserializer: RequestUploadingFileResponse.fromJson);
  }

  Future<List<GalleryCategory>> getGalleryCategoryList() {
    return _getResponseList<GalleryCategory>(HttpMethod.get, _buildHoohUri("gallery/categoriesV4"), deserializer: GalleryCategory.fromJson);
  }

  Future<List<GalleryImage>> getGalleryImageList(String id, int page, int width, {int size = 20}) {
    return _getResponseList<GalleryImage>(
        HttpMethod.get, _buildHoohUri("gallery/categories/$id/imagesV3", params: {"page": page, "width": width, "size": size}),
        deserializer: GalleryImage.fromJson);
  }

  Future<List<GalleryImage>> searchGalleryImageList(String key, int page, int width, bool showFavoriteStatus, {int size = 20}) {
    return _getResponseList<GalleryImage>(HttpMethod.get,
        _buildHoohUri("gallery/images/query", params: {"page": page, "width": width, "size": size, "key": key, "show_favorite_status": showFavoriteStatus}),
        deserializer: GalleryImage.fromJson);
  }

  Future<void> setGalleryImageFavorite(String id, bool favorite) {
    return _getResponseObject<void>(favorite ? HttpMethod.put : HttpMethod.delete, _buildHoohUri("gallery/images/$id/favorite"));
  }

  Future<bool> uploadFile(String url, Uint8List fileBytes) async {
    int id = Random().nextInt(10000);
    logRequest(id, HttpMethod.put, Uri.parse(url), {'data': "<file bytes>"});
    var response = await http.put(Uri.parse(url), body: fileBytes);
    logResponse(id, response, null);
    if (response.statusCode >= 200 && response.statusCode < 400) {
      return true;
    } else {
      return false;
    }
  }

  Future<DownloadInfo?> downloadBytes(String url, String filename) async {
    try {
      int id = Random().nextInt(10000);
      logRequest(id, HttpMethod.get, Uri.parse(url), null);
      final response = await http.get(Uri.parse(url));
      logResponse(id, response, null);
      if (response.contentLength == 0) {
        return null;
      }
      return DownloadInfo(bytes: response.bodyBytes, filename: filename);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<M> _getResponseObject<M>(HttpMethod method, Uri uri,
      {Map<String, dynamic>? extraHeaders, Map<String, dynamic>? body, M Function(Map<String, dynamic>)? deserializer}) async {
    extraHeaders ??= {};
    _prepareHeaders(extraHeaders);
    var data = await _getRawResponse(method, uri, extraHeaders: extraHeaders, body: body, deserializer: deserializer);
    if (data is HoohApiErrorResponse) {
      return Future.error(data);
    } else {
      if (deserializer != null) {
        return deserializer(data as Map<String, dynamic>);
      } else {
        return Future.value(null);
      }
    }
  }

  Future<List<M>> _getResponseList<M>(HttpMethod method, Uri uri,
      {Map<String, dynamic>? extraHeaders, Map<String, dynamic>? body, M Function(Map<String, dynamic>)? deserializer}) async {
    extraHeaders ??= {};
    // extraHeaders["Authorization"] =
    //     "Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJBY2Nlc3NUb2tlbiIsInVzZXJfc2FmZV9pZCI6ImRlOTkyYWVkLWEyYzctNGEzZS05YzZkLTU3YmM3YTEyNWYwYyIsImV4cCI6MTY1MDA5ODgwNywiaWF0IjoxNjQ3NTA2ODA3fQ.pcqeofRYGPQ0fvIIn5ZdSOkEGNyU-trFaqWcyDBOAvJyi-bHSLhqCzwOjDRDF6fJ-BzqMQkg-_IRr61Hq4baBg";
    _prepareHeaders(extraHeaders);
    var data = await _getRawResponse(method, uri, extraHeaders: extraHeaders, body: body, deserializer: deserializer);
    if (data is HoohApiErrorResponse) {
      return Future.error(data);
    } else {
      if (deserializer != null) {
        return (data as List<dynamic>).map((e) => deserializer(e as Map<String, dynamic>)).toList();
      } else {
        return Future.value([]);
      }
    }
  }

// Future<String> _getUserAgent() async {
//
// }
  void _prepareHeaders(Map<String, dynamic> headers) {
    String? token = preferences.getString(Preferences.keyUserAccessToken);
    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }
    headers["Content-Type"] = "application/json";
    headers["User-Agent"] = deviceInfo.getUserAgent();
  }

  Future<dynamic> _getRawResponse<M>(HttpMethod method, Uri uri,
      {Map<String, dynamic>? extraHeaders, Map<String, dynamic>? body, M Function(Map<String, dynamic>)? deserializer}) async {
    int id = Random().nextInt(10000);
    logRequest(id, method, uri, body);
    http.Response response;
    try {
      switch (method) {
        case HttpMethod.get:
          response = await _client.get(uri, headers: extraHeaders?.map((key, value) => MapEntry(key, value.toString())));
          break;
        case HttpMethod.post:
          response = await _client.post(uri, body: json.encode(body), headers: extraHeaders?.map((key, value) => MapEntry(key, value.toString())));
          break;
        case HttpMethod.put:
          response = await _client.put(uri, body: json.encode(body), headers: extraHeaders?.map((key, value) => MapEntry(key, value.toString())));
          break;
        case HttpMethod.delete:
          response = await _client.delete(uri, body: json.encode(body), headers: extraHeaders?.map((key, value) => MapEntry(key, value.toString())));
          break;
      }
    } catch (e) {
      print(e);
      return;
    }
    dynamic returnedJson;
    try {
      returnedJson = jsonDecode(utf8.decode(response.bodyBytes));
      logResponse(id, response, returnedJson);
    } catch (e) {
      debugPrint(e.toString());
    }
    if (response.statusCode >= 200 && response.statusCode < 400) {
      //success
      return returnedJson;
    } else {
      //failed
      HoohApiErrorResponse hoohApiErrorResponse;
      if (returnedJson != null) {
        hoohApiErrorResponse = HoohApiErrorResponse.fromJson(returnedJson);
        if (hoohApiErrorResponse.message.isEmpty) {
          hoohApiErrorResponse.message = "<未返回错误信息>";
        }
      } else {
        hoohApiErrorResponse = HoohApiErrorResponse(500, "<无法解析>", "<无法解析>");
      }
      return hoohApiErrorResponse;
    }
  }

  void logResponse(int id, http.Response response, returnedJson) {
    debugPrint("[RESPONSE $id] HTTP ${response.statusCode}\njson=${prettyJson(returnedJson)}");
  }

  void logRequest(int id, HttpMethod method, Uri uri, Map<String, dynamic>? body) {
    debugPrint(
        "[REQUEST  $id] ${method.name.toUpperCase()} url=${uri.toString()},\n query:${"\n" + prettyJson(uri.queryParameters)},\n body:${body == null ? "" : ("\n" + prettyJson(body))}");
  }

  Uri _buildUri(bool ssl, String host, String path, {Map<String, dynamic>? params}) {
    var queryParameters = params?.map((key, value) => MapEntry(key, value.toString()));
    return ssl ? Uri.https(host, path, queryParameters) : Uri.http(host, path, queryParameters);
  }

  Uri _buildHoohUri(String path, {bool hasPrefix = true, Map<String, dynamic>? params}) {
    var unencodedPath = (hasPrefix ? serverPathPrefix : "") + path;
    return _buildUri(true, host, unencodedPath, params: params);
  }

  void _prepareHttpClient() {
    _client = http.Client();
  }
//   ///准备一个可以支持Let's Encrypt证书的client
//   void _prepareHttpClient() {
// //     /// This is LetsEncrypt's self-signed trusted root certificate authority
// //     /// certificate, issued under common name: ISRG Root X1 (Internet Security
// //     /// Research Group).  Used in handshakes to negotiate a Transport Layer Security
// //     /// connection between endpoints.  This certificate is missing from older devices
// //     /// that don't get OS updates such as Android 7 and older.  But, we can supply
// //     /// this certificate manually to our HttpClient via SecurityContext so it can be
// //     /// used when connecting to URLs protected by LetsEncrypt SSL certificates.
// //     /// PEM format LE self-signed cert from here: https://letsencrypt.org/certificates/
// //     const String ISRG_X1 = """-----BEGIN CERTIFICATE-----
// // MIIFazCCA1OgAwIBAgIRAIIQz7DSQONZRGPgu2OCiwAwDQYJKoZIhvcNAQELBQAw
// // TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
// // cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMTUwNjA0MTEwNDM4
// // WhcNMzUwNjA0MTEwNDM4WjBPMQswCQYDVQQGEwJVUzEpMCcGA1UEChMgSW50ZXJu
// // ZXQgU2VjdXJpdHkgUmVzZWFyY2ggR3JvdXAxFTATBgNVBAMTDElTUkcgUm9vdCBY
// // MTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAK3oJHP0FDfzm54rVygc
// // h77ct984kIxuPOZXoHj3dcKi/vVqbvYATyjb3miGbESTtrFj/RQSa78f0uoxmyF+
// // 0TM8ukj13Xnfs7j/EvEhmkvBioZxaUpmZmyPfjxwv60pIgbz5MDmgK7iS4+3mX6U
// // A5/TR5d8mUgjU+g4rk8Kb4Mu0UlXjIB0ttov0DiNewNwIRt18jA8+o+u3dpjq+sW
// // T8KOEUt+zwvo/7V3LvSye0rgTBIlDHCNAymg4VMk7BPZ7hm/ELNKjD+Jo2FR3qyH
// // B5T0Y3HsLuJvW5iB4YlcNHlsdu87kGJ55tukmi8mxdAQ4Q7e2RCOFvu396j3x+UC
// // B5iPNgiV5+I3lg02dZ77DnKxHZu8A/lJBdiB3QW0KtZB6awBdpUKD9jf1b0SHzUv
// // KBds0pjBqAlkd25HN7rOrFleaJ1/ctaJxQZBKT5ZPt0m9STJEadao0xAH0ahmbWn
// // OlFuhjuefXKnEgV4We0+UXgVCwOPjdAvBbI+e0ocS3MFEvzG6uBQE3xDk3SzynTn
// // jh8BCNAw1FtxNrQHusEwMFxIt4I7mKZ9YIqioymCzLq9gwQbooMDQaHWBfEbwrbw
// // qHyGO0aoSCqI3Haadr8faqU9GY/rOPNk3sgrDQoo//fb4hVC1CLQJ13hef4Y53CI
// // rU7m2Ys6xt0nUW7/vGT1M0NPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNV
// // HRMBAf8EBTADAQH/MB0GA1UdDgQWBBR5tFnme7bl5AFzgAiIyBpY9umbbjANBgkq
// // hkiG9w0BAQsFAAOCAgEAVR9YqbyyqFDQDLHYGmkgJykIrGF1XIpu+ILlaS/V9lZL
// // ubhzEFnTIZd+50xx+7LSYK05qAvqFyFWhfFQDlnrzuBZ6brJFe+GnY+EgPbk6ZGQ
// // 3BebYhtF8GaV0nxvwuo77x/Py9auJ/GpsMiu/X1+mvoiBOv/2X/qkSsisRcOj/KK
// // NFtY2PwByVS5uCbMiogziUwthDyC3+6WVwW6LLv3xLfHTjuCvjHIInNzktHCgKQ5
// // ORAzI4JMPJ+GslWYHb4phowim57iaztXOoJwTdwJx4nLCgdNbOhdjsnvzqvHu7Ur
// // TkXWStAmzOVyyghqpZXjFaH3pO3JLF+l+/+sKAIuvtd7u+Nxe5AW0wdeRlN8NwdC
// // jNPElpzVmbUq4JUagEiuTDkHzsxHpFKVK7q4+63SM1N95R1NbdWhscdCb+ZAJzVc
// // oyi3B43njTOQ5yOf+1CceWxG1bQVs5ZufpsMljq4Ui0/1lvh+wjChP4kqKOJ2qxq
// // 4RgqsahDYVvTH9w7jXbyLeiNdd8XM2w9U/t7y0Ff/9yi0GE44Za4rF2LN9d11TPA
// // mRGunUHBcnWEvgJBQl9nJEiU0Zsnvgc/ubhPgXRR4Xq37Z0j4r7g1SgEEzwxA57d
// // emyPxgcYxn/eR44/KJ4EBs+lVDR3veyJm+kXQ99b21/+jh5Xos1AnX5iItreGCc=
// // -----END CERTIFICATE-----""";
// //     HttpClient customHttpClient(String? cert) {
// //       SecurityContext context = SecurityContext.defaultContext;
// //       try {
// //         if (cert != null) {
// //           Uint8List bytes = Uint8List.fromList(utf8.encode(cert));
// //           context.setTrustedCertificatesBytes(bytes);
// //         }
// //         print('createHttpClient() - cert added!');
// //       } on TlsException catch (e) {
// //         print(e);
// //       } finally {}
// //       HttpClient httpClient = HttpClient(context: context);
// //       return httpClient;
// //     }
// //
// //     /// Use package:http Client with our custom dart:io HttpClient with added
// //     /// LetsEncrypt trusted certificate
// //     http.Client createLEClient() {
// //       IOClient ioClient;
// //       ioClient = IOClient(customHttpClient(ISRG_X1));
// //       return ioClient;
// //     }
// //
// //     /// Using a custom package:http Client
// //     /// that will work with devices missing LetsEncrypt
// //     /// ISRG Root X1 certificates, like old Android 7 devices.
// //     _client = createLEClient();
//     _client = http.Client();
//   }
}

class DownloadInfo {
  Uint8List? bytes;
  String? filename;

  DownloadInfo({this.bytes, this.filename});
}
