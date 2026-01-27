import 'package:flutter/material.dart';

class DockMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const DockMenu({
    required this.selectedIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A3428), Color(0xFF5D4037)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D4037).withOpacity(0.5),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _DockItem(
            icon: Icons.home_rounded,
            label: 'Home',
            isSelected: selectedIndex == 0,
            onTap: () => onTap(0),
          ),
          _DockItem(
            icon: Icons.menu_book_rounded,
            label: 'Mushaf',
            isSelected: selectedIndex == 1,
            onTap: () => onTap(1),
          ),
          _DockItem(
            icon: Icons.edit_note_rounded,
            label: 'Catatan',
            isSelected: selectedIndex == 2,
            onTap: () => onTap(2),
          ),
          _DockItem(
            icon: Icons.mosque_rounded,
            label: 'Sholat',
            isSelected: selectedIndex == 3,
            onTap: () => onTap(3),
          ),
          _DockItem(
            icon: Icons.settings_rounded,
            label: 'Setting',
            isSelected: selectedIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _DockItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DockItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_DockItem> createState() => _DockItemState();
}

class _DockItemState extends State<_DockItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? Colors.white.withOpacity(0.25)
              : _isPressed
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Icon(
          widget.icon,
          color:
              widget.isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          size: widget.isSelected ? 28 : 26,
        ),
      ),
    );
  }
}
