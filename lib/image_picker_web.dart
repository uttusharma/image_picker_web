library image_picker_web;

export 'src/Models/Types.dart';

import 'dart:async';
import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/web_image_picker.dart';
import 'src/Models/Types.dart';

class ImagePickerWeb {
  static void registerWith(Registrar registrar) {
    final channel = MethodChannel(
        'image_picker_web', const StandardMethodCodec(), registrar.messenger);
    final instance = WebImagePicker();
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'pickImage':
          return await instance.pickImage();
        case 'pickVideo':
          return await instance.pickVideo();
        default:
          throw MissingPluginException();
      }
    });
  }

  static const MethodChannel _methodChannel =
      const MethodChannel('image_picker_web');

  Future<html.File?> _pickFile(String type) async {
    final html.FileUploadInputElement input = html.FileUploadInputElement();
    input..accept = '$type/*';
    input.click();
    await input.onChange.first;
    if (input.files!.isEmpty) return null;
    return input.files![0];
  }

  static Future<dynamic> getImage({required ImageType outputType}) async {
    if (!(outputType is ImageType)) {
      throw ArgumentError(
          'outputType has to be from Type: ImageType if you call getImage()');
    }
    switch (outputType) {
      case ImageType.file:
        return await ImagePickerWeb()._pickFile('image');
        break;
      case ImageType.bytes:
        final data =
            await (_methodChannel.invokeMapMethod<String, dynamic>('pickImage')
                as Future<Map<String, dynamic>>);
        final imageData = base64.decode(data['data']);
        return imageData;
        break;
      case ImageType.widget:
        final data =
            await (_methodChannel.invokeMapMethod<String, dynamic>('pickImage')
                as Future<Map<String, dynamic>>);
        final imageName = data['name'];
        final imageData = base64.decode(data['data']);
        return Image.memory(imageData, semanticLabel: imageName);
        break;
      default:
        return null;
        break;
    }
  }

  static Future<MediaInfo> get getImageInfo async {
    final data =
        await (_methodChannel.invokeMapMethod<String, dynamic>('pickImage')
            as Future<Map<String, dynamic>>);
    MediaInfo _webImageInfo = MediaInfo();
    _webImageInfo.fileName = data['name'];
    _webImageInfo.base64 = data['data'];
    _webImageInfo.base64WithScheme = data['data_scheme'];
    _webImageInfo.data = base64.decode(data['data']);
    return _webImageInfo;
  }

  static Future<dynamic> getVideo({required VideoType outputType}) async {
    if (!(outputType is VideoType)) {
      throw ArgumentError(
          'outputType has to be from Type: VideoType if you call getVideo()');
    }
    switch (outputType) {
      case VideoType.file:
        return await ImagePickerWeb()._pickFile('video');
        break;
      case VideoType.bytes:
        final data =
            await (_methodChannel.invokeMapMethod<String, dynamic>('pickVideo')
                as Future<Map<String, dynamic>>);
        final imageData = base64.decode(data['data']);
        return imageData;
        break;
      default:
        return null;
        break;
    }
  }

  static Future<MediaInfo> get getVideoInfo async {
    final data =
        await (_methodChannel.invokeMapMethod<String, dynamic>('pickVideo')
            as Future<Map<String, dynamic>>);
    MediaInfo _webVideoInfo = MediaInfo();
    _webVideoInfo.fileName = data['name'];
    _webVideoInfo.base64 = data['data'];
    _webVideoInfo.base64WithScheme = data['data_scheme'];
    _webVideoInfo.data = base64.decode(data['data']);
    return _webVideoInfo;
  }
}
