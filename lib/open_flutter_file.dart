import 'package:flutter/services.dart';

const platform = MethodChannel('your_channel_id');

Future<void> openFile(String filePath) async {
  try {
    await platform.invokeMethod('openFile', {'filePath': filePath});
  } catch (e) {
    print('Error opening file: $e');
  }
}
