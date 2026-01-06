import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart' show XFile;

class ImageService {
  /// 处理衣物照片：压缩并保存到应用文档目录
  /// [tempPath]: 原始图片的临时路径（例如来自 ImagePicker）
  /// 返回保存后的完整路径
  static Future<String> processAndSaveImage(String tempPath) async {
    // 1. 获取应用文档目录
    final directory = await getApplicationDocumentsDirectory();
    
    // 2. 生成唯一的文件名 (时间戳 + 原始扩展名)
    final fileName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(tempPath)}';
    final targetPath = p.join(directory.path, fileName);

    // 3. 使用 flutter_image_compress 压缩图片
    // 保证宽度不超过 1024，质量为 80
    final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
      tempPath,
      targetPath,
      minWidth: 1024,
      minHeight: 1024,
      quality: 80,
    );

    if (compressedFile == null) {
      throw Exception('图片压缩失败');
    }

    return compressedFile.path;
  }
}

