import 'web_storage_stub.dart' if (dart.library.html) 'web_storage_web.dart' as storage;

void saveWebStorage(String key, String value) {
  storage.saveWebData(key, value);
}

String? getWebStorage(String key) {
  return storage.getWebData(key);
}
