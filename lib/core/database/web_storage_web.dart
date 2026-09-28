// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void saveWebData(String key, String value) {
  try {
    html.window.localStorage[key] = value;
  } catch (_) {}
}

String? getWebData(String key) {
  try {
    return html.window.localStorage[key];
  } catch (_) {
    return null;
  }
}
