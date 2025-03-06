// import 'dart:io';
// import 'dart:js';
// import 'dart:typed_data';

// import 'package:flutter/services.dart';
// import 'package:js/js.dart';
// import 'package:js/js_util.dart';
// import 'package:path_provider/path_provider.dart';

// @JS('_extractText')
// external dynamic _extractText(String imagePath, dynamic args);

// // FlutterTesseractOcr Class
// class FlutterTesseractOcr {
//   /// image to  text
//   ///```
//   /// String _ocrText = await FlutterTesseractOcr.extractText(url, language: langs, args: {
//   ///    "preserve_interword_spaces": "1",});
//   ///```
//   static extractText(String imagePath, {String? language, Map? args}) async {
//     var promiseData =
//         _extractText(imagePath, jsify({"language": language, "args": args!}));
//     var rtn = await promiseToFuture(promiseData);
//     return rtn;
//   }

//   /// image to  html text(hocr)
//   ///```
//   /// String _ocrHocr = await FlutterTesseractOcr.extractText(url, language: langs, args: {
//   ///    "preserve_interword_spaces": "1",});
//   ///```
//   static Future<String> extractHocr(String imagePath,
//       {String? language, Map? args}) async {
//     var promiseData = _extractText(
//         imagePath,
//         jsify({
//           "language": language,
//           "args": {...args!, "tessjs_create_hocr": "1"}
//         }));
//     var rtn = await promiseToFuture(promiseData);
//     return rtn;
//   }

//   //web not support
//   static Future<String> getTessdataPath() async {
//     return "";
//   }

//   //web not support
//   static Future<String> _loadTessData() async {
//     return "";
//   }

//   //web not support
//   static Future _copyTessDataToAppDocumentsDirectory(
//       String tessdataDirectory) async {}
// }
