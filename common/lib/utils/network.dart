import 'dart:convert';
import 'dart:math';

import 'package:common/models/gallery_category.dart';
import 'package:common/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:pretty_json/pretty_json.dart';

//顶层变量
Network network = Network._internal();

enum HttpMethod { get, post, put, delete }

class Network {
  /// 顶层变量，单例模式
  Network._internal();

  static const host = "api.fygtapp.cn";
  static const serverPathPrefix = "v2/";

  final http.Client _client = http.Client();
  bool _isUsingLocalServer = false;

  Network();

  Future<User> getUser(String userSafeId) {
    return _getResponseObject<User>(HttpMethod.get, _buildFygtUri("users/$userSafeId"), deserializer: User.fromJson);
  }

  Future<List<GalleryCategory>> getGalleryCategoryList() {
    return _getResponseList(HttpMethod.get, _buildFygtUri("/v2/gallery/categoriesV4"), deserializer: GalleryCategory.fromJson);
  }

  Future<M> _getResponseObject<M>(HttpMethod method, Uri uri,
      {Map<String, dynamic>? extraHeaders,
      Map<String, dynamic>? queryParams,
      Map<String, dynamic>? body,
      M Function(Map<String, dynamic>)? deserializer}) async {
    if (deserializer != null) {
      return deserializer(await _getRawResponse(method, uri, queryParams: queryParams, extraHeaders: extraHeaders, body: body, deserializer: deserializer)
          as Map<String, dynamic>);
    } else {
      return Future.value(null);
    }
  }

  Future<List<M>> _getResponseList<M>(HttpMethod method, Uri uri,
      {Map<String, dynamic>? extraHeaders,
      Map<String, dynamic>? queryParams,
      Map<String, dynamic>? body,
      M Function(Map<String, dynamic>)? deserializer}) async {
    if (deserializer != null) {
      return (await _getRawResponse(method, uri, queryParams: queryParams, extraHeaders: extraHeaders, body: body, deserializer: deserializer)
              as List<Map<String, dynamic>>)
          .map((e) => deserializer(e))
          .toList();
    } else {
      return Future.value([]);
    }
  }

  Future<dynamic> _getRawResponse<M>(HttpMethod method, Uri uri,
      {Map<String, dynamic>? extraHeaders,
      Map<String, dynamic>? queryParams,
      Map<String, dynamic>? body,
      M Function(Map<String, dynamic>)? deserializer}) async {
    int id = Random().nextInt(10000);
    debugPrint(
        "[REQUEST  $id] url=${uri.toString()},\n query:${queryParams == null ? "" : ("\n" + prettyJson(queryParams))},\n body:${body == null ? "" : ("\n" + prettyJson(body))}");
    http.Response response;
    switch (method) {
      case HttpMethod.get:
        response = await _client.get(uri);
        break;
      case HttpMethod.post:
        response = await _client.post(uri, body: body);
        break;
      case HttpMethod.put:
        response = await _client.put(uri, body: body);
        break;
      case HttpMethod.delete:
        response = await _client.delete(uri, body: body);
        break;
    }
    var json = jsonDecode(utf8.decode(response.bodyBytes));
    debugPrint("[RESPONSE $id] json=${prettyJson(json)}");
    return json;
  }

  Uri _buildUri(bool ssl, String host, String path, {Map<String, dynamic>? params}) {
    var queryParameters = params?.map((key, value) => MapEntry(key, value.toString()));
    return ssl ? Uri.https(host, path, queryParameters) : Uri.http(host, path, queryParameters);
  }

  Uri _buildFygtUri(String path, {bool hasPrefix = true, Map<String, dynamic>? params}) {
    var unencodedPath = (hasPrefix ? serverPathPrefix : "") + path;
    return _buildUri(true, host, unencodedPath, params: params);
  }
}
