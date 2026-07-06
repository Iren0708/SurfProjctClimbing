/// Публичные auth-эндпоинты без Bearer (LOGIC-001).
class ApiPaths {
  const ApiPaths._();

  static const requestAuthCode = '/auth/request-code';
  static const verifyAuthCode = '/auth/verify-code';
  static const refreshToken = '/auth/refresh';
  static const logout = '/auth/logout';

  static const publicAuthPaths = {
    requestAuthCode,
    verifyAuthCode,
    refreshToken,
  };

  static bool isPublicAuthPath(String path) {
    final normalized = _normalize(path);
    return publicAuthPaths.any((publicPath) => normalized.endsWith(publicPath));
  }

  static String _normalize(String path) {
    final uri = Uri.tryParse(path);
    return uri?.path ?? path;
  }
}
