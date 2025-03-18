import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  // 讀取資料
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  // 寫入資料
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  // 刪除特定資料
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  // 刪除所有資料
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
