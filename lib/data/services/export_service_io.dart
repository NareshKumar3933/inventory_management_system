import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> saveCsvFile(String csvContent, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsString(csvContent, encoding: utf8);
  return file.path;
}
