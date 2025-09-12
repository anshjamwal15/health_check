import 'package:flutter/material.dart';
import 'package:health_check/widgets/home_content.dart';
import 'package:health_check/screens/schedule/schedule_page.dart';
import 'package:health_check/screens/tasks/task_page.dart';
import 'package:health_check/screens/profile/profile_setup_page.dart';
import 'package:health_check/utils/shared_prefrences.dart';

class SharedNavigationWrapper extends StatefulWidget {
  final int initialIndex;
  
  const SharedNavigationWrapper({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<SharedNavigationWrapper> createState() => _SharedNavigationWrapperState();
}

class _SharedNavigationWrapperState extends State<SharedNavigationWrapper> {
  int currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _pages = [
    const HomeContent(),
    const SchedulePage(),
    const TaskPage(),
    const ProfileSetupPage(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
    _loadBottomNavIndex();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadBottomNavIndex() async {
    final savedIndex = await SharedPreferencesUtil.getBottomNavIndex();
    setState(() {
      currentIndex = savedIndex;
    });
    _pageController.jumpToPage(savedIndex);
  }

  Future<void> onTabTapped(int index) async {
    setState(() {
      currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    // Save the selected tab index
    await SharedPreferencesUtil.saveBottomNavIndex(index);
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.grey,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.grey,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
          SharedPreferencesUtil.saveBottomNavIndex(index);
        },
        children: _pages,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildNavItem(Icons.home, "Home", 0)),
              Expanded(child: _buildNavItem(Icons.schedule, "Schedule", 1)),
              Expanded(child: _buildNavItem(Icons.task, "Tasks", 2)),
              Expanded(child: _buildNavItem(Icons.person, "Profile", 3)),
            ],
          ),
        ),
      ),
    );
  }
}
