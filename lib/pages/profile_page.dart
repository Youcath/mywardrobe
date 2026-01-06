import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/wardrobe_provider.dart';
import 'theme_selector_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<WardrobeProvider>();
    
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // User Info Section
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(Icons.person, size: 60, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 16),
                const Text(
                  '时尚达人',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Text('探索无限穿搭可能'),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          // Wardrobe Statistics Section
          const Text('衣橱统计', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 15),
          
          _buildStatsCard(context, provider),
          
          const SizedBox(height: 30),
          
          // Settings Section
          const Text('设置', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          _buildSettingsItem(
            context,
            icon: Icons.palette_outlined,
            title: '主题设置',
            subtitle: '公主风、御姐风、简约风随心切换',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ThemeSelectorPage()),
              );
            },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.notifications_none,
            title: '通知提醒',
            subtitle: '穿搭灵感及时送达',
            onTap: () {},
          ),
          _buildSettingsItem(
            context,
            icon: Icons.help_outline,
            title: '帮助与反馈',
            onTap: () {},
          ),
          const SizedBox(height: 20),
          
          // App Info
          const Center(
            child: Text(
              'MyWardrobe v1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, WardrobeProvider provider) {
    final theme = Theme.of(context);
    final categoryData = provider.categoryCounts;
    final mostWorn = provider.mostWornOutfit;
    final colorData = provider.colorCounts;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Category Distribution (Pie Chart)
            const Text('衣物分类占比', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (categoryData.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('暂无衣物数据', style: TextStyle(color: Colors.grey)),
              ))
            else
              SizedBox(
                height: 200,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: PieChart(
                        PieChartData(
                          sections: _buildCategorySections(categoryData, theme),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: categoryData.entries.map((e) => _buildLegendItem(e.key, e.value, theme)).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            
            const Divider(height: 40),

            // 2. Most Used Outfit
            const Text('利用率最高', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (mostWorn == null)
              const Text('暂无穿搭记录', style: TextStyle(color: Colors.grey, fontSize: 14))
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.stars_rounded, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mostWorn.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('场合: ${mostWorn.category}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const Divider(height: 40),

            // 3. Color Palette
            const Text('我的调色盘', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            if (colorData.isEmpty)
              const Text('暂无颜色数据', style: TextStyle(color: Colors.grey, fontSize: 14))
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: colorData.entries.map((e) {
                  return Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(e.key),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${e.value}件', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildCategorySections(Map<String, int> data, ThemeData theme) {
    final total = data.values.fold(0, (sum, val) => sum + val);
    final List<Color> colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      Colors.orangeAccent,
      Colors.tealAccent,
      Colors.indigoAccent,
    ];

    int i = 0;
    return data.entries.map((e) {
      final percentage = (e.value / total) * 100;
      final color = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        color: color,
        value: e.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Widget _buildLegendItem(String label, int value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Text('$value', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
