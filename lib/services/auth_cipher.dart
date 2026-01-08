import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';

class AuthCipher {
  static final encrypt.Key _key =
      encrypt.Key.fromUtf8('12345678901234567890123456789012');

  static final encrypt.Encrypter _encrypter =
      encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));

  static encrypt.IV newIv() => encrypt.IV.fromSecureRandom(16);

  static String encryptText(String plain, encrypt.IV iv) {
    return _encrypter.encrypt(plain, iv: iv).base64;
  }

  static String decryptText(String base64Cipher, String ivBase64) {
    try {
      final iv = encrypt.IV.fromBase64(ivBase64);
      return _encrypter.decrypt64(base64Cipher, iv: iv);
    } catch (e) {
      debugPrint('DECRYPT ERROR: $e');
      return '';
    }
  }
}