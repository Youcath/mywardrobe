import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'wardrobe_page.dart';
import 'outfits_page.dart';
import 'calendar_page.dart';
import 'add_clothing_page.dart';
import 'create_outfit_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const WardrobePage(),
    const OutfitsPage(),
    const CalendarPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    // 逻辑修正：index 0, 1 是衣橱和穿搭，2 是加号菜单（不在 Stack 里），3, 4 是日历和个人
    int stackIndex = _currentIndex;
    if (_currentIndex == 2) {
      stackIndex = 0; // 防止越界，实际上 2 会弹出菜单
    } else if (_currentIndex > 2) {
      stackIndex = _currentIndex - 1;
    }

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: stackIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            _showAddMenu(context);
            return;
          }
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('记录你的时尚灵感', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMenuOption(
                  context,
                  icon: Icons.add_photo_alternate_rounded,
                  label: '添加新单品',
                  color: theme.colorScheme.primary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddClothingPage()));
                  },
                ),
                _buildMenuOption(
                  context,
                  icon: Icons.auto_awesome_rounded,
                  label: '设计新搭配',
                  color: const Color(0xFFFFB74D), // 橙黄色代表创意
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateOutfitPage()));
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(BuildContext context, {
    required IconData icon, 
    required String label, 
    required Color color, 
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 35),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}



