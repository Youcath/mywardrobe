import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wardrobe_provider.dart';

class CreateOutfitScreen extends StatefulWidget {
  const CreateOutfitScreen({super.key});

  @override
  State<CreateOutfitScreen> createState() => _CreateOutfitScreenState();
}

class _CreateOutfitScreenState extends State<CreateOutfitScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedCategory = '约会';
  final List<String> _outfitCategories = ['约会', '上班', '游玩', '日常'];
  final List<String> _selectedItemIds = [];

  void _toggleSelection(String id) {
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
        const SnackBar(content: Text('请输入名称并至少选择一件衣物')),
      );
      return;
    }

    Provider.of<WardrobeProvider>(context, listen: false).addOutfit(
      _nameController.text,
      _selectedCategory,
      _selectedItemIds,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('创建穿搭')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '穿搭名称 (如: 甜美约会)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('场景选择:'),
                Wrap(
                  spacing: 10,
                  children: _outfitCategories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = cat);
                      },
                      selectedColor: const Color(0xFFFF8DA1),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text('选择衣物 (可多选)', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Consumer<WardrobeProvider>(
              builder: (context, provider, child) {
                final clothes = provider.allClothes;
                if (clothes.isEmpty) {
                  return const Center(child: Text('衣橱里还没有衣服哦'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: clothes.length,
                  itemBuilder: (context, index) {
                    final item = clothes[index];
                    final isSelected = _selectedItemIds.contains(item.id);

                    return GestureDetector(
                      onTap: () => _toggleSelection(item.id),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: isSelected ? const Color(0xFFFF8DA1) : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: Image.file(
                                File(item.imagePath),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Positioned(
                              top: 5,
                              right: 5,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Color(0xFFFF8DA1),
                                child: Icon(Icons.check, size: 16, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _saveOutfit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('完成创建'),
            ),
          ),
        ],
      ),
    );
  }
}

