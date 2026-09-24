import 'package:flutter/material.dart';
import 'listPage.dart';
import 'favorite_empty_screen.dart'; // ✅ YEH IMPORT ADD KARO

class FilterChipsWidget extends StatefulWidget {
  final ColorScheme colorScheme;
  final Function(String) onFilterSelected;

  const FilterChipsWidget({
    super.key,
    required this.colorScheme,
    required this.onFilterSelected,
  });

  @override
  State<FilterChipsWidget> createState() => _FilterChipsWidgetState();
}

class _FilterChipsWidgetState extends State<FilterChipsWidget> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Unread', 'Favorites', 'Groups'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 37,
      padding: const EdgeInsets.only(left: 16, right: 10, top: 4, bottom: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: _filters.length + 1,
        itemBuilder: (context, index) {
          if (index == _filters.length) {
            return Padding(
              padding: const EdgeInsets.only(left: 4),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewListPage(),
                    ),
                  );
                },
                child: Container(
                  width: 33,
                  height: 33,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: widget.colorScheme.surface,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: widget.colorScheme.onSurface.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 15,
                    color: widget.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            );
          }

          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () {
                // ✅ FAVORITES CHIP PY TAP PY SCREEN OPEN HO GI
                if (filter == 'Favorites') {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: const FavoritesScreen(),
                        );
                      },
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(begin: begin, end: end).chain(
                          CurveTween(curve: curve),
                        );
                        var offsetAnimation = animation.drive(tween);
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 250),
                    ),
                  );
                  return; // Selected state change nahi hogi
                }

                setState(() => _selectedFilter = filter);
                widget.onFilterSelected(filter);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF4A5568)
                      : widget.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFF4A5568)
                        : widget.colorScheme.onSurface.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected 
                        ? Colors.white
                        : widget.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}