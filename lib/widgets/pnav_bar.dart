import 'package:flutter/material.dart';

class PnavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isVertical;

  const PnavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final navigationItems = [
      _buildNavigationItem(
        icon: Icons.home,
        label: 'Home',
        index: 0,
      ),
      _buildNavigationItem(
        icon: Icons.chat_bubble, // Filled chat bubble icon
        label: 'Learner',
        index: 1,
      ),
      _buildNavigationItem(
        icon: Icons.bookmark,
        label: 'Bookmarks',
        index: 2,
      ),
      _buildNavigationItem(
        icon: Icons.person,
        label: 'Profile',
        index: 3,
      ),
    ];

    if (isVertical) {
      return Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 20),
            ...navigationItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: item,
                )),
          ],
        ),
      );
    }

    return BottomNavigationBar(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 28),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble, size: 28),
          label: 'Learner',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark, size: 28),
          label: 'Bookmarks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, size: 28),
          label: 'Profile',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: const Color(0xFF0D47A1),
      unselectedItemColor: Colors.black,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
      ),
      onTap: onItemTapped,
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D47A1).withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? const Color(0xFF0D47A1) : Colors.black,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF0D47A1) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
