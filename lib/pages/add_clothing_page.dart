import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/wardrobe_provider.dart';
import '../services/image_service.dart';
import '../services/database_helper.dart';
import '../services/background_removal_service.dart';
import '../models/clothing_item.dart';

class AddClothingPage extends StatefulWidget {
  const AddClothingPage({super.key});

  @override
  State<AddClothingPage> createState() => _AddClothingPageState();
}

class _AddClothingPageState extends State<AddClothingPage> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  final _nameController = TextEditingController();
  String _selectedCategory = '上衣';
  Color _selectedColor = Colors.pinkAccent;
  final List<String> _selectedSeasons = [];
  final List<String> _tags = [];
  final _tagController = TextEditingController();
  bool _isLoading = false;
  String _loadingMessage = '';

  final List<String> _categories = ['上衣', '裤子', '裙子', '外套', '鞋子', '配饰'];
  final List<String> _seasons = ['春', '夏', '秋', '冬'];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _addTag(String value) {
    if (value.isNotEmpty && !_tags.contains(value)) {
      setState(() {
        _tags.add(value.trim());
        _tagController.clear();
      });
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择衣物颜色'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() => _selectedColor = color);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _saveClothing() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择或拍摄衣物照片')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _loadingMessage = BackgroundRemovalService.isConfigured 
            ? '正在去除背景...' 
            : '正在准备图片...';
      });

      try {
        String imageToProcess = _image!.path;

        // 1. 仅在 API Key 已配置时调用背景去除服务
        if (BackgroundRemovalService.isConfigured) {
          final String? noBgPath = await BackgroundRemovalService.removeBackground(_image!.path);
          if (noBgPath != null) {
            imageToProcess = noBgPath;
          }
        }

        setState(() => _loadingMessage = '正在压缩保存...');

        // 2. 调用图片压缩和保存函数
        final String permanentPath = await ImageService.processAndSaveImage(imageToProcess);

        // 3. 构造模型对象
        final combinedTags = [..._selectedSeasons, ..._tags].join(',');
        final newItem = ClothingItem(
          name: _nameController.text,
          category: _selectedCategory,
          imagePath: permanentPath,
          tags: combinedTags,
          colorValue: _selectedColor.value,
        );

        // 4. 存入数据库
        await DatabaseHelper().insertItem(newItem);

        if (mounted) {
          await Provider.of<WardrobeProvider>(context, listen: false).loadClothes();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('衣物已成功添加到衣橱 ✨')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('处理失败: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('添加新衣物'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. 图片选择区域
              GestureDetector(
                onTap: () => _showImageSourcePicker(),
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 50, color: theme.colorScheme.primary),
                            const SizedBox(height: 10),
                            const Text('点击上传衣物照片', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 30),

              // 2. 名称输入
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '衣物名称',
                  hintText: '例如：白色蕾丝连衣裙',
                  prefixIcon: const Icon(Icons.edit_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                validator: (value) => (value == null || value.isEmpty) ? '请输入名称' : null,
              ),
              const SizedBox(height: 20),

              // 3. 分类选择 (Dropdown)
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: '分类',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value!),
              ),
              const SizedBox(height: 20),

              // 4. 颜色选择
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                ),
                title: const Text('衣物主色调'),
                trailing: TextButton(
                  onPressed: _showColorPicker,
                  child: const Text('点击选择'),
                ),
              ),
              const Divider(),

              // 5. 季节选择 (Wrap + FilterChip)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('适用季节', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Wrap(
                spacing: 10,
                children: _seasons.map((season) {
                  final isSelected = _selectedSeasons.contains(season);
                  return FilterChip(
                    label: Text(season),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSeasons.add(season);
                        } else {
                          _selectedSeasons.remove(season);
                        }
                      });
                    },
                    selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: theme.colorScheme.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // 6. 标签输入 (Wrap + Chip)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('个性标签', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: '输入标签并回车 (如：复古)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => _addTag(_tagController.text),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onSubmitted: _addTag,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () => setState(() => _tags.remove(tag)),
                    deleteIcon: const Icon(Icons.cancel, size: 18),
                    backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),

              // 保存按钮
              ElevatedButton(
                onPressed: _isLoading ? null : _saveClothing,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading 
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        ),
                        const SizedBox(width: 12),
                        Text(_loadingMessage, style: const TextStyle(fontSize: 16, color: Colors.white)),
                      ],
                    )
                  : const Text('保存到衣橱', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
