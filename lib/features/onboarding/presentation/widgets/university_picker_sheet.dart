import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/ethiopian_universities.dart';

/// Opens the searchable university picker as a blurred bottom sheet.
/// Background blurs while open; returns to normal when dismissed or
/// when a university is selected. Returns the name, or null if dismissed.
Future<String?> showUniversityPickerSheet(BuildContext context,
    {String? current}) {
  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (BuildContext dialogContext,
        Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return _UniversityPickerSheet(current: current);
    },
    transitionBuilder: (BuildContext dialogContext,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child) {
      final CurvedAnimation curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position:
              Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
                  .animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _UniversityPickerSheet extends StatefulWidget {
  const _UniversityPickerSheet({this.current});

  final String? current;

  @override
  State<_UniversityPickerSheet> createState() =>
      _UniversityPickerSheetState();
}

class _UniversityPickerSheetState extends State<_UniversityPickerSheet> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    final String query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return ethiopianUniversities;
    return ethiopianUniversities
        .where((String u) => u.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    final List<String> list = _filtered;

    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        color: Colors.black.withOpacity(0.45),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {}, // Taps inside the sheet don't dismiss it.
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  height: screen.height * 0.82,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundAlt,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(26)),
                    border: Border(
                      top: BorderSide(
                          color: Colors.white.withOpacity(0.10), width: 1),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 10),
                      Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Select your university',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _search,
                          onChanged: (_) => setState(() {}),
                          textInputAction: TextInputAction.search,
                          style: const TextStyle(
                              fontSize: 14.5, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Search universities…',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary
                                  .withOpacity(0.7),
                              fontSize: 14.5,
                            ),
                            prefixIcon: const Icon(Icons.search_rounded,
                                size: 20, color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.08),
                                  width: 1.2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: AppColors.accent, width: 1.6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: list.isEmpty
                            ? Center(
                                child: Text(
                                  'No universities found.',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14),
                                ),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 24),
                                itemCount: list.length,
                                itemBuilder:
                                    (BuildContext context, int index) {
                                  final String name = list[index];
                                  final bool selected =
                                      name == widget.current;
                                  return _UniversityTile(
                                    name: name,
                                    selected: selected,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      Navigator.of(context).pop(name);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UniversityTile extends StatelessWidget {
  const _UniversityTile({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withOpacity(0.14)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.accent.withOpacity(0.7)
                : Colors.white.withOpacity(0.06),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.accent : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColors.accent
                      : Colors.white.withOpacity(0.18),
                  width: 1.2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}