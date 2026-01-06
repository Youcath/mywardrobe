import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../providers/wardrobe_provider.dart';
import '../services/database_helper.dart';

class ClothingDetailPage extends StatefulWidget {
  final ClothingItem item;

  const ClothingDetailPage({super.key, required this.item});

  @override
  State<ClothingDetailPage> createState() => _ClothingDetailPageState();
}

class _ClothingDetailPageState extends State<ClothingDetailPage> {
  late ClothingItem _currentItem;
  final List<String> _allSeasons = ['春', '夏', '秋', '冬'];

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
  }

  // 从 tags 字符串中分离出季节和普通标签
  List<String> get _currentSeasons {
    final allTags = _currentItem.tags.split(',').where((t) => t.isNotEmpty).toList();
    return allTags.where((t) => _allSeasons.contains(t)).toList();
  }

  List<String> get _currentNormalTags {
    final allTags = _currentItem.tags.split(',').where((t) => t.isNotEmpty).toList();
    return allTags.where((t) => !_allSeasons.contains(t)).toList();
  }

  // 修改季节
  void _editSeasons() async {
    List<String> selectedSeasons = List.from(_currentSeasons);
    
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('设置适用季节', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    children: _allSeasons.map((season) {
                      final isSelected = selectedSeasons.contains(season);
                      return FilterChip(
                        label: Text(season),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              selectedSeasons.add(season);
                            } else {
                              selectedSeasons.remove(season);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('确定'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    // 更新数据
    final newTags = [...selectedSeasons, ..._currentNormalTags].join(',');
    final updatedItem = ClothingItem(
      id: _currentItem.id,
      name: _currentItem.name,
      category: _currentItem.category,
      imagePath: _currentItem.imagePath,
      tags: newTags,
    );

    await DatabaseHelper().updateItem(updatedItem);
    
    if (mounted) {
      setState(() {
        _currentItem = updatedItem;
      });
      // 通知 Provider 刷新，确保主页同步
      Provider.of<WardrobeProvider>(context, listen: false).loadClothes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seasonsDisplay = _currentSeasons.isEmpty ? '未设置' : _currentSeasons.join('、');

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentItem.name.isNotEmpty ? _currentItem.name : '衣物详情'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 大图展示
            Hero(
              tag: 'clothing_image_${_currentItem.id}',
              child: InteractiveViewer(
                child: Image.file(
                  File(_currentItem.imagePath),
                  fit: BoxFit.contain,
                  height: 400,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 400,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image_outlined, size: 100, color: Colors.grey),
                  ),
                ),
              ),
            ),

            // 2. 信息详情
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _currentItem.name.isNotEmpty ? _currentItem.name : '时尚单品',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _currentItem.category,
                          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 适用季节 (可点击修改)
                  InkWell(
                    onTap: _editSeasons,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          const Text('适用季节', style: TextStyle(color: Colors.grey)),
                          const Spacer(),
                          Text(seasonsDisplay, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 标签展示
                  const Text('个性标签', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  if (_currentNormalTags.isEmpty)
                    const Text('暂无标签', style: TextStyle(color: Colors.grey))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _currentNormalTags.map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: theme.colorScheme.secondary.withOpacity(0.05),
                        side: BorderSide(color: theme.colorScheme.secondary.withOpacity(0.1)),
                      )).toList(),
                    ),
                  
                  const SizedBox(height: 60),

                  // 删除按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmDelete(context),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('从衣橱中删除'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.red.withOpacity(0.2)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除衣物'),
        content: const Text('确定要将这件衣物从衣橱中删除吗？此操作不可撤销，且会同时删除本地图片文件。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final provider = Provider.of<WardrobeProvider>(context, listen: false);
              if (_currentItem.id != null) {
                await provider.deleteClothingItem(_currentItem.id!);
                if (context.mounted) {
                  Navigator.pop(context); // 关闭对话框
                  Navigator.pop(context); // 返回列表页
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已从衣橱中移除 ✨')),
                  );
                }
              }
            },
            child: const Text('确定删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
