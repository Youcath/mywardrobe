import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/clothing_item.dart';
import '../services/database_helper.dart';
import '../providers/wardrobe_provider.dart';
import '../theme/color_schemes.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/clothing_card.dart';
import 'clothing_detail_page.dart';
import 'add_clothing_page.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  String _selectedCategory = '全部';
  String _searchQuery = '';
  List<String> _selectedSeasons = [];
  
  final Map<String, IconData> _categoryIcons = {
    '全部': Icons.grid_view_rounded,
    '上衣': Icons.checkroom_rounded,
    '裤子': Icons.layers_rounded,
    '裙子': Icons.woman_rounded,
    '外套': Icons.wb_cloudy_rounded,
    '鞋子': Icons.ice_skating_rounded,
    '配饰': Icons.watch_rounded,
  };

  @override
  void initState() {
    super.initState();
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('高级筛选', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          setModalState(() => _selectedSeasons = []);
                          setState(() {});
                        },
                        child: const Text('重置'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('按季节筛选', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: ['春', '夏', '秋', '冬'].map((season) {
                      final isSelected = _selectedSeasons.contains(season);
                      return FilterChip(
                        label: Text(season),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              _selectedSeasons.add(season);
                            } else {
                              _selectedSeasons.remove(season);
                            }
                          });
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('完成'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = theme.extension<ThemeGradients>()?.primaryGradient;
    final provider = context.watch<WardrobeProvider>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withOpacity(0.8),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Row(
            children: [
              const Text('我的衣橱'),
              const Spacer(),
              if (provider.currentWeather != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getWeatherIcon(provider.currentWeather?.weatherIcon),
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${provider.currentWeather?.temperature?.celsius?.toStringAsFixed(0)}°C',
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: gradient),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              onPressed: _showFilterDialog,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(130),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: '搜索我的单品...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                CategoryFilterBar(
                  selectedCategory: _selectedCategory,
                  categories: _categoryIcons,
                  onCategorySelected: (cat) {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            // 1. 今日穿搭建议区域
            if (provider.recommendedOutfits.isNotEmpty)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Text(
                        '✨ 今日穿搭建议',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: provider.recommendedOutfits.length,
                        itemBuilder: (context, index) {
                          final outfit = provider.recommendedOutfits[index];
                          final items = provider.getClothingItemsForOutfit(outfit);
                          if (items.isEmpty) return const SizedBox.shrink();
                          
                          return Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 15, bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                    child: Image.file(
                                      File(items[0].imagePath),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    outfit.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
              ),
            
            // 2. 衣服网格
            FutureBuilder<List<ClothingItem>>(
              future: DatabaseHelper().queryAllItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                }

                var clothes = snapshot.data ?? [];

                // 过滤逻辑
                if (_selectedCategory != '全部') {
                  clothes = clothes.where((item) => item.category == _selectedCategory).toList();
                }
                if (_searchQuery.isNotEmpty) {
                  clothes = clothes.where((item) => 
                    item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    item.tags.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                }

                if (clothes.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('没有找到匹配的单品')),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    itemBuilder: (context, index) {
                      final item = clothes[index];
                      return ClothingCard(
                        item: item,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ClothingDetailPage(item: item)),
                          ).then((_) => setState(() {}));
                        },
                      );
                    },
                    childCount: clothes.length,
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddClothingPage()),
            );
            setState(() {});
          },
          label: const Text('添加单品'),
          icon: const Icon(Icons.add),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String? iconCode) {
    switch (iconCode) {
      case '01d': return Icons.wb_sunny_rounded;
      case '01n': return Icons.nightlight_round;
      case '02d':
      case '02n':
      case '03d':
      case '03n':
      case '04d':
      case '04n': return Icons.cloud_rounded;
      case '09d':
      case '09n':
      case '10d':
      case '10n': return Icons.umbrella_rounded;
      case '11d':
      case '11n': return Icons.thunderstorm_rounded;
      case '13d':
      case '13n': return Icons.ac_unit_rounded;
      case '50d':
      case '50n': return Icons.foggy;
      default: return Icons.wb_cloudy_rounded;
    }
  }
}



