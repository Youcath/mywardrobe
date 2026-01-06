import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wardrobe_provider.dart';

class CreateOutfitPage extends StatefulWidget {
  const CreateOutfitPage({super.key});

  @override
  State<CreateOutfitPage> createState() => _CreateOutfitPageState();
}

class _CreateOutfitPageState extends State<CreateOutfitPage> {
  final _nameController = TextEditingController();
  String _selectedOccasion = '约会';
  final List<String> _occasions = ['约会', '上班', '游玩', '日常'];
  final List<int> _selectedItemIds = [];

  void _toggleSelection(int? id) {
    if (id == null) return;
    setState(() {
      if (_selectedItemIds.contains(id)) {
        _selectedItemIds.remove(id);
      } else {
        _selectedItemIds.add(id);
      }
    });
  }

  void _saveOutfit() {
    if (_nameController.text.isEmpty || _selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入方案名称并至少选择一件衣物')),
      );
      return;
    }

    Provider.of<WardrobeProvider>(context, listen: false).addOutfit(
      _nameController.text,
      _selectedOccasion,
      _selectedItemIds,
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('搭配方案已保存 ✨')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<WardrobeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('创建搭配'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveOutfit,
            child: const Text('保存', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          // 顶部信息输入
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '方案名称',
                    hintText: '如：周五约会装',
                    prefixIcon: const Icon(Icons.edit_note),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('选择场合', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: _occasions.map((occasion) {
                    final isSelected = _selectedOccasion == occasion;
                    return ChoiceChip(
                      label: Text(occasion),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedOccasion = occasion);
                      },
                      selectedColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text('选择单品 (已选 ${_selectedItemIds.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          // 衣物选择网格
          Expanded(
            child: provider.allClothes.isEmpty
                ? const Center(child: Text('衣橱里还没有衣服哦'))
                : GridView.builder(
                    padding: const EdgeInsets.all(15),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: provider.allClothes.length,
                    itemBuilder: (context, index) {
                      final item = provider.allClothes[index];
                      final isSelected = _selectedItemIds.contains(item.id);

                      return GestureDetector(
                        onTap: () => _toggleSelection(item.id),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(File(item.imagePath), fit: BoxFit.cover),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 5,
                                right: 5,
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: theme.colorScheme.primary,
                                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

