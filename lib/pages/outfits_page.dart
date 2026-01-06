import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wardrobe_provider.dart';
import 'create_outfit_page.dart';

class OutfitsPage extends StatefulWidget {
  const OutfitsPage({super.key});

  @override
  State<OutfitsPage> createState() => _OutfitsPageState();
}

class _OutfitsPageState extends State<OutfitsPage> {
  String _selectedOccasion = '全部';
  final List<String> _occasions = ['全部', '约会', '上班', '游玩', '日常'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('搭配方案'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: _occasions.map((occ) {
                final isSelected = _selectedOccasion == occ;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(occ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedOccasion = occ;
                      });
                    },
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: Consumer<WardrobeProvider>(
        builder: (context, provider, child) {
          var outfits = provider.allOutfits;
          if (_selectedOccasion != '全部') {
            outfits = outfits.where((o) => o.category == _selectedOccasion).toList();
          }

          if (outfits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_motion_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('还没创建搭配方案哦~', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateOutfitPage()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('立即去创建'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 100),
            itemCount: outfits.length,
            itemBuilder: (context, index) {
              final outfit = outfits[index];
              final items = provider.getClothingItemsForOutfit(outfit);

              return Card(
                elevation: 4,
                shadowColor: theme.colorScheme.primary.withOpacity(0.1),
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      title: Text(
                        outfit.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Container(
                        margin: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(Icons.sell_outlined, size: 14, color: theme.colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              outfit.category,
                              style: TextStyle(color: theme.colorScheme.primary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                        onPressed: () => _confirmDelete(context, provider, outfit.id),
                      ),
                    ),
                    if (items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 20, bottom: 20),
                        child: Text('此搭配方案中没有找到衣物', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      )
                    else
                      Container(
                        height: 130,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: items.length,
                          itemBuilder: (context, idx) {
                            final item = items[idx];
                            return Container(
                              margin: const EdgeInsets.only(right: 15),
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(
                                      File(item.imagePath),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: Colors.grey[100],
                                        child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                                      ),
                                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                        if (wasSynchronouslyLoaded) return child;
                                        return AnimatedOpacity(
                                          opacity: frame == null ? 0 : 1,
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.easeOut,
                                          child: child,
                                        );
                                      },
                                    ),
                                    // 渐变底部，增加质感
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      height: 30,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90), // 将 FAB 向上移，避开底部导航栏
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateOutfitPage()),
            );
          },
          label: const Text('创建搭配'),
          icon: const Icon(Icons.add),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WardrobeProvider provider, int? id) {
    if (id == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除确认'),
        content: const Text('确定要删除这个搭配方案吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              provider.deleteOutfit(id);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}


