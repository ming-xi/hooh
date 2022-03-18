import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:common/models/gallery_category.dart';
import 'package:common/models/gallery_image.dart';
import 'package:common/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:pretty_json/pretty_json.dart';

//顶层变量
Network network = Network._internal();

enum HttpMethod { get, post, put, delete }

class Network {
  /// 顶层变量，单例模式
  Network._internal() {
    _prepareHttpClient();
  }

  static const host = "api.fygtapp.cn";
  static const serverPathPrefix = "v2/";

  late final http.Client _client;
  bool _isUsingLocalServer = false;

  // Network();

  Future<User> getUser(String userSafeId) {
    return _getResponseObject<User>(HttpMethod.get, _buildFygtUri("users/$userSafeId"), deserializer: User.fromJson);
  }

  Future<List<GalleryCategory>> getGalleryCategoryList() {
    return _getResponseList<GalleryCategory>(HttpMethod.get, _buildFygtUri("gallery/categoriesV4"), deserializer: GalleryCategory.fromJson);
  }

  Future<List<GalleryImage>> getGalleryImageList(String id, int page, int width,{int size = 20}) {
    return _getResponseList<GalleryImage>(HttpMethod.get, _buildFygtUri("gallery/categories/$id/imagesV3",params: {"page": page, "width": width, "size": size}), deserializer: GalleryImage.fromJson);
  }

  Future <void> setGalleryImageFavorited(String id, bool favorited) {
    return _getResponseObject<void>(favorited ? HttpMethod.put : HttpMethod.delete, _buildFygtUri("gallery/images/{$id}}/favorite"));
  }

  Future<M> _getResponseObject<M>(HttpMethod method, Uri uri,
      {Map<String, dynamic>? extraHeaders,
      Map<String, dynamic>? queryParams,
      Map<String, dynamic>? body,
      M Function(Map<String, dynamic>)? deserializer}) async {
    if (deserializer != null) {
      extraHeaders ??= {};
        extraHeaders["Authorization"]= "Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJBY2Nlc3NUb2tlbiIsInVzZXJfc2FmZV9pZCI6ImRlOTkyYWVkLWEyYzctNGEzZS05YzZkLTU3YmM3YTEyNWYwYyIsImV4cCI6MTY1MDA5ODgwNywiaWF0IjoxNjQ3NTA2ODA3fQ.pcqeofRYGPQ0fvIIn5ZdSOkEGNyU-trFaqWcyDBOAvJyi-bHSLhqCzwOjDRDF6fJ-BzqMQkg-_IRr61Hq4baBg";

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
      extraHeaders ??= {};
      extraHeaders["Authorization"]= "Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJBY2Nlc3NUb2tlbiIsInVzZXJfc2FmZV9pZCI6ImRlOTkyYWVkLWEyYzctNGEzZS05YzZkLTU3YmM3YTEyNWYwYyIsImV4cCI6MTY1MDA5ODgwNywiaWF0IjoxNjQ3NTA2ODA3fQ.pcqeofRYGPQ0fvIIn5ZdSOkEGNyU-trFaqWcyDBOAvJyi-bHSLhqCzwOjDRDF6fJ-BzqMQkg-_IRr61Hq4baBg";

      return (await _getRawResponse(method, uri, queryParams: queryParams, extraHeaders: extraHeaders, body: body, deserializer: deserializer) as List<dynamic>)
          .map((e) => deserializer(e as Map<String, dynamic>))
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
        response = await _client.get(uri,headers: extraHeaders?.map((key, value) => MapEntry(key, value.toString())));
        break;
      case HttpMethod.post:
        response = await _client.post(uri, body: body, headers: extraHeaders?.map((key, value) => MapEntry(key, value.toString())));
        break;
      case HttpMethod.put:
        response = await _client.put(uri, body: body, headers: extraHeaders?.map((key, value) => MapEntry(key, value.toString())));
        break;
      case HttpMethod.delete:
        response = await _client.delete(uri, body: body, headers: extraHeaders?.map((key, value) => MapEntry(key, value.toString())));
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

  ///准备一个可以支持Let's Encrypt证书的client
  void _prepareHttpClient() {
    /// This is LetsEncrypt's self-signed trusted root certificate authority
    /// certificate, issued under common name: ISRG Root X1 (Internet Security
    /// Research Group).  Used in handshakes to negotiate a Transport Layer Security
    /// connection between endpoints.  This certificate is missing from older devices
    /// that don't get OS updates such as Android 7 and older.  But, we can supply
    /// this certificate manually to our HttpClient via SecurityContext so it can be
    /// used when connecting to URLs protected by LetsEncrypt SSL certificates.
    /// PEM format LE self-signed cert from here: https://letsencrypt.org/certificates/
    const String ISRG_X1 = """-----BEGIN CERTIFICATE-----
MIIFazCCA1OgAwIBAgIRAIIQz7DSQONZRGPgu2OCiwAwDQYJKoZIhvcNAQELBQAw
TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMTUwNjA0MTEwNDM4
WhcNMzUwNjA0MTEwNDM4WjBPMQswCQYDVQQGEwJVUzEpMCcGA1UEChMgSW50ZXJu
ZXQgU2VjdXJpdHkgUmVzZWFyY2ggR3JvdXAxFTATBgNVBAMTDElTUkcgUm9vdCBY
MTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAK3oJHP0FDfzm54rVygc
h77ct984kIxuPOZXoHj3dcKi/vVqbvYATyjb3miGbESTtrFj/RQSa78f0uoxmyF+
0TM8ukj13Xnfs7j/EvEhmkvBioZxaUpmZmyPfjxwv60pIgbz5MDmgK7iS4+3mX6U
A5/TR5d8mUgjU+g4rk8Kb4Mu0UlXjIB0ttov0DiNewNwIRt18jA8+o+u3dpjq+sW
T8KOEUt+zwvo/7V3LvSye0rgTBIlDHCNAymg4VMk7BPZ7hm/ELNKjD+Jo2FR3qyH
B5T0Y3HsLuJvW5iB4YlcNHlsdu87kGJ55tukmi8mxdAQ4Q7e2RCOFvu396j3x+UC
B5iPNgiV5+I3lg02dZ77DnKxHZu8A/lJBdiB3QW0KtZB6awBdpUKD9jf1b0SHzUv
KBds0pjBqAlkd25HN7rOrFleaJ1/ctaJxQZBKT5ZPt0m9STJEadao0xAH0ahmbWn
OlFuhjuefXKnEgV4We0+UXgVCwOPjdAvBbI+e0ocS3MFEvzG6uBQE3xDk3SzynTn
jh8BCNAw1FtxNrQHusEwMFxIt4I7mKZ9YIqioymCzLq9gwQbooMDQaHWBfEbwrbw
qHyGO0aoSCqI3Haadr8faqU9GY/rOPNk3sgrDQoo//fb4hVC1CLQJ13hef4Y53CI
rU7m2Ys6xt0nUW7/vGT1M0NPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNV
HRMBAf8EBTADAQH/MB0GA1UdDgQWBBR5tFnme7bl5AFzgAiIyBpY9umbbjANBgkq
hkiG9w0BAQsFAAOCAgEAVR9YqbyyqFDQDLHYGmkgJykIrGF1XIpu+ILlaS/V9lZL
ubhzEFnTIZd+50xx+7LSYK05qAvqFyFWhfFQDlnrzuBZ6brJFe+GnY+EgPbk6ZGQ
3BebYhtF8GaV0nxvwuo77x/Py9auJ/GpsMiu/X1+mvoiBOv/2X/qkSsisRcOj/KK
NFtY2PwByVS5uCbMiogziUwthDyC3+6WVwW6LLv3xLfHTjuCvjHIInNzktHCgKQ5
ORAzI4JMPJ+GslWYHb4phowim57iaztXOoJwTdwJx4nLCgdNbOhdjsnvzqvHu7Ur
TkXWStAmzOVyyghqpZXjFaH3pO3JLF+l+/+sKAIuvtd7u+Nxe5AW0wdeRlN8NwdC
jNPElpzVmbUq4JUagEiuTDkHzsxHpFKVK7q4+63SM1N95R1NbdWhscdCb+ZAJzVc
oyi3B43njTOQ5yOf+1CceWxG1bQVs5ZufpsMljq4Ui0/1lvh+wjChP4kqKOJ2qxq
4RgqsahDYVvTH9w7jXbyLeiNdd8XM2w9U/t7y0Ff/9yi0GE44Za4rF2LN9d11TPA
mRGunUHBcnWEvgJBQl9nJEiU0Zsnvgc/ubhPgXRR4Xq37Z0j4r7g1SgEEzwxA57d
emyPxgcYxn/eR44/KJ4EBs+lVDR3veyJm+kXQ99b21/+jh5Xos1AnX5iItreGCc=
-----END CERTIFICATE-----""";
    HttpClient customHttpClient(String? cert) {
      SecurityContext context = SecurityContext.defaultContext;
      try {
        if (cert != null) {
          Uint8List bytes = Uint8List.fromList(utf8.encode(cert));
          context.setTrustedCertificatesBytes(bytes);
        }
        print('createHttpClient() - cert added!');
      } on TlsException catch (e) {
        print(e);
      } finally {}
      HttpClient httpClient = HttpClient(context: context);
      return httpClient;
    }

    /// Use package:http Client with our custom dart:io HttpClient with added
    /// LetsEncrypt trusted certificate
    http.Client createLEClient() {
      IOClient ioClient;
      ioClient = IOClient(customHttpClient(ISRG_X1));
      return ioClient;
    }

    /// Using a custom package:http Client
    /// that will work with devices missing LetsEncrypt
    /// ISRG Root X1 certificates, like old Android 7 devices.
    _client = createLEClient();
  }
}
