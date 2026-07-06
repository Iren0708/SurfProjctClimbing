import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/core/storage/secure_token_storage.dart';
import 'package:vertical_mobile/core/storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),
);
