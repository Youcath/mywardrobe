import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class BackgroundRemovalService {
  // TODO: 请在这里填入你的 Remove.bg API Key
  // 获取地址: https://www.remove.bg/api
  static const String _apiKey = 'YOUR_REMOVE_BG_API_KEY';
  static const String _apiUrl = 'https://api.remove.bg/v1.0/removebg';

  /// 检查是否已经配置了有效的 API Key
  static bool get isConfigured => 
      _apiKey != 'YOUR_REMOVE_BG_API_KEY' && _apiKey.isNotEmpty;

  /// 调用 Remove.bg API 去除图片背景
  /// [imagePath]: 原始图片的本地路径
  /// 返回去背景后的透明 PNG 临时文件路径
  static Future<String?> removeBackground(String imagePath) async {
    if (!isConfigured) return null;

    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'image_file': await MultipartFile.fromFile(imagePath),
        'size': 'auto', // 可选: auto, preview, full
      });

      final response = await dio.post(
        _apiUrl,
        data: formData,
        options: Options(
          headers: {'X-Api-Key': _apiKey},
          responseType: ResponseType.bytes, // 接口返回的是图片二进制数据
        ),
      );

      if (response.statusCode == 200) {
        // 创建临时文件保存去背景后的图片
        final tempDir = await getTemporaryDirectory();
        final fileName = 'no_bg_${DateTime.now().millisecondsSinceEpoch}.png';
        final tempFile = File(p.join(tempDir.path, fileName));
        
        await tempFile.writeAsBytes(response.data);
        return tempFile.path;
      }
    } catch (e) {
      print('背景去除失败: $e');
      if (e is DioException) {
        print('错误详情: ${e.response?.data}');
      }
    }
    return null;
  }
}

