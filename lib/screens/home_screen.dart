import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wardrobe_provider.dart';
import 'add_clothing_screen.dart';
import 'outfit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['全部', '上衣', '裤子', '裙子', '鞋子', '配饰'];
  String _selectedCategory = '全部';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的衣橱'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '单品'),
            Tab(text: '搭配'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildClothesTab(),
          _buildOutfitsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddClothingScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateOutfitScreen()),
            );
          }
        },
        backgroundColor: const Color(0xFFFF8DA1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildClothesTab() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Row(
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                  selectedColor: const Color(0xFFFF8DA1),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: Consumer<WardrobeProvider>(
            builder: (context, provider, child) {
              final clothes = _selectedCategory == '全部'
                  ? provider.allClothes
                  : provider.getClothesByCategory(_selectedCategory);

              if (clothes.isEmpty) {
                return const Center(child: Text('这里空空如也，快去添加吧~'));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(15),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: clothes.length,
                itemBuilder: (context, index) {
                  final item = clothes[index];
                  return GestureDetector(
                    onLongPress: () {
                      _showDeleteDialog(item.id, true);
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Image.file(
                        File(item.imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOutfitsTab() {
    return Consumer<WardrobeProvider>(
      builder: (context, provider, child) {
        final outfits = provider.allOutfits;
        if (outfits.isEmpty) {
          return const Center(child: Text('还没创建搭配方案哦~'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: outfits.length,
          itemBuilder: (context, index) {
            final outfit = outfits[index];
            final items = provider.getClothingItemsForOutfit(outfit);

            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          outfit.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8BBD0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(outfit.category, style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        itemBuilder: (context, idx) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(items[idx].imagePath),
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _showDeleteDialog(outfit.id, false),
                        child: const Text('删除', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(String id, bool isClothing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除？'),
        content: Text(isClothing ? '确定要从衣橱中移除这件衣服吗？' : '确定要删除这个搭配方案吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final provider = Provider.of<WardrobeProvider>(context, listen: false);
              if (isClothing) {
                provider.deleteClothingItem(id);
              } else {
                provider.deleteOutfit(id);
              }
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

