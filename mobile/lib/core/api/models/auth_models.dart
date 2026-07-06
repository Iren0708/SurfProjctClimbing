import 'package:vertical_mobile/core/api/models/client_models.dart';

class RequestCodeRequest {
  const RequestCodeRequest({required this.phone});

  final String phone;

  Map<String, dynamic> toJson() => {'phone': phone};
}

class RequestCodeResponse {
  const RequestCodeResponse({
    required this.ttlSeconds,
    required this.resendAfterSeconds,
  });

  final int ttlSeconds;
  final int resendAfterSeconds;

  factory RequestCodeResponse.fromJson(Map<String, dynamic> json) {
    return RequestCodeResponse(
      ttlSeconds: json['ttl_seconds'] as int,
      resendAfterSeconds: json['resend_after_seconds'] as int,
    );
  }
}

class VerifyCodeRequest {
  const VerifyCodeRequest({
    required this.phone,
    required this.code,
  });

  final String phone;
  final String code;

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'code': code,
      };
}

class TokenPair {
  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  factory TokenPair.fromJson(Map<String, dynamic> json) {
    return TokenPair(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'token_type': tokenType,
        'expires_in': expiresIn,
      };
}

class RefreshTokenRequest {
  const RefreshTokenRequest({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() => {'refresh_token': refreshToken};
}

class VerifyCodeResponse {
  const VerifyCodeResponse({
    required this.tokens,
    required this.client,
    required this.isNew,
  });

  final TokenPair tokens;
  final ClientDto client;
  final bool isNew;

  factory VerifyCodeResponse.fromJson(Map<String, dynamic> json) {
    return VerifyCodeResponse(
      tokens: TokenPair.fromJson(json['tokens'] as Map<String, dynamic>),
      client: ClientDto.fromJson(json['client'] as Map<String, dynamic>),
      isNew: json['is_new'] as bool,
    );
  }
}
