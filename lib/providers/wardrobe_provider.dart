import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../models/wear_log.dart';
import '../services/database_helper.dart';
import '../services/weather_service.dart';

class WardrobeProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final WeatherService _weatherService = WeatherService();

  List<ClothingItem> _allClothes = [];
  List<Outfit> _allOutfits = [];
  List<WearLog> _allWearLogs = [];
  
  Weather? _currentWeather;
  List<Outfit> _recommendedOutfits = [];

  List<ClothingItem> get allClothes => _allClothes;
  List<Outfit> get allOutfits => _allOutfits;
  List<WearLog> get allWearLogs => _allWearLogs;
  Weather? get currentWeather => _currentWeather;
  List<Outfit> get recommendedOutfits => _recommendedOutfits;

  // 统计相关
  Map<String, int> get categoryCounts {
    final Map<String, int> counts = {};
    for (var item in _allClothes) {
      counts[item.category] = (counts[item.category] ?? 0) + 1;
    }
    return counts;
  }

  Map<int, int> get colorCounts {
    final Map<int, int> counts = {};
    for (var item in _allClothes) {
      counts[item.colorValue] = (counts[item.colorValue] ?? 0) + 1;
    }
    return counts;
  }

  Outfit? get mostWornOutfit {
    if (_allWearLogs.isEmpty) return null;
    
    final Map<int, int> counts = {};
    for (var log in _allWearLogs) {
      counts[log.outfitId!] = (counts[log.outfitId!] ?? 0) + 1;
    }
    
    if (counts.isEmpty) return null;
    
    final sortedIds = counts.keys.toList()..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    return getOutfitById(sortedIds.first);
  }

  WardrobeProvider() {
    loadData();
    fetchWeatherAndRecommend();
  }

  Future<void> fetchWeatherAndRecommend() async {
    _currentWeather = await _weatherService.getCurrentWeather();
    _updateRecommendations();
    notifyListeners();
  }

  void _updateRecommendations() {
    if (_currentWeather == null) {
      _recommendedOutfits = [];
      return;
    }

    final temp = _currentWeather!.temperature?.celsius;
    final currentSeason = _weatherService.getSeasonByTemp(temp);
    
    // 简单的推荐逻辑：如果穿搭中的大部分衣物包含当前季节标签
    _recommendedOutfits = _allOutfits.where((outfit) {
      final items = getClothingItemsForOutfit(outfit);
      if (items.isEmpty) return false;
      
      int matchCount = 0;
      for (var item in items) {
        if (currentSeason == '春秋') {
          if (item.tags.contains('春') || item.tags.contains('秋')) matchCount++;
        } else {
          if (item.tags.contains(currentSeason)) matchCount++;
        }
      }
      return matchCount >= items.length / 2; // 超过一半衣物符合季节
    }).toList();
  }

  Future<void> loadData() async {
    await loadClothes();
    await loadOutfits();
    await loadWearLogs();
    _updateRecommendations();
  }

  // 加载所有衣物
  Future<void> loadClothes() async {
    _allClothes = await _dbHelper.queryAllItems();
    notifyListeners();
  }

  // 加载所有穿搭
  Future<void> loadOutfits() async {
    final maps = await _dbHelper.getAllOutfits();
    _allOutfits = maps.map((m) => Outfit.fromMap(m)).toList();
    notifyListeners();
  }

  // 加载所有穿着记录
  Future<void> loadWearLogs() async {
    final maps = await _dbHelper.getWearLogs();
    _allWearLogs = maps.map((m) => WearLog.fromMap(m)).toList();
    notifyListeners();
  }

  // 按分类获取衣物
  Future<List<ClothingItem>> getClothesByCategory(String category) async {
    if (category == '全部') return _allClothes;
    return await _dbHelper.getClothingByCategory(category);
  }

  // 添加衣物
  Future<void> addClothingItem(ClothingItem item) async {
    await _dbHelper.insertItem(item);
    await loadClothes();
  }

  // 删除衣物
  Future<void> deleteClothingItem(int id) async {
    await _dbHelper.deleteItem(id);
    // 同时从所有穿搭中移除此衣物 ID
    for (var outfit in _allOutfits) {
      if (outfit.clothingItemIds.contains(id)) {
        outfit.clothingItemIds.remove(id);
        await _dbHelper.addOutfit(outfit.toMap());
      }
    }
    await loadData();
  }

  // 添加穿搭
  Future<void> addOutfit(String name, String category, List<int> clothingItemIds) async {
    final newOutfit = Outfit(
      name: name,
      category: category,
      clothingItemIds: clothingItemIds,
      createdDate: DateTime.now(),
    );
    await _dbHelper.addOutfit(newOutfit.toMap());
    await loadOutfits();
  }

  // 删除穿搭
  Future<void> deleteOutfit(int id) async {
    await _dbHelper.deleteOutfit(id);
    await loadOutfits();
  }

  // 获取穿搭中的衣物
  List<ClothingItem> getClothingItemsForOutfit(Outfit outfit) {
    return outfit.clothingItemIds
        .map((id) => _allClothes.firstWhere((item) => item.id == id, orElse: () => ClothingItem(name: '已删除', category: '', imagePath: '', tags: '')))
        .where((item) => item.name != '已删除')
        .toList();
  }

  // 穿搭记录相关
  Future<void> addWearLog(String date, int outfitId) async {
    await _dbHelper.insertWearLog(date, outfitId);
    await loadWearLogs();
  }

  Future<void> deleteWearLog(int id) async {
    await _dbHelper.deleteWearLog(id);
    await loadWearLogs();
  }

  Outfit? getOutfitById(int id) {
    try {
      return _allOutfits.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  List<WearLog> getWearLogsForDate(DateTime date) {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return _allWearLogs.where((log) => log.date == dateStr).toList();
  }
}
