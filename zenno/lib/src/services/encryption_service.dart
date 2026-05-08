import 'package:encrypt/encrypt.dart' as enc;

class EncryptionService {
  static final _key = enc.Key.fromUtf8('zenno_secure_key_32bytes_padded!');
  static final _iv = enc.IV.fromUtf8('zenno_iv_16bytes');

  static String encryptText(String plainText) {
    final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  static String decryptText(String encryptedBase64) {
    try {
      final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
      return encrypter.decrypt64(encryptedBase64, iv: _iv);
    } catch (_) {
      return encryptedBase64;
    }
  }

  static String maskCardNumber(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return cardNumber;
    return '**** **** **** ${digits.substring(digits.length - 4)}';
  }
}
