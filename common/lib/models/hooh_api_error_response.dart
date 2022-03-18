import 'package:json_annotation/json_annotation.dart';

part 'hooh_api_error_response.g.dart';

@JsonSerializable()
class HoohApiErrorResponse {
  @JsonKey(name: "error_code")
  int errorCode;
  @JsonKey(name: "message", defaultValue: "")
  String message;
  @JsonKey(name: "dev_message", defaultValue: "")
  String devMessage;

  HoohApiErrorResponse(this.errorCode, this.message, this.devMessage);

  factory HoohApiErrorResponse.fromJson(Map<String, dynamic> json) => _$HoohApiErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HoohApiErrorResponseToJson(this);

  @override
  String toString() {
    return 'HoohApiErrorResponse{errorCode: $errorCode, message: $message, devMessage: $devMessage}';
  }
}
