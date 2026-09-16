import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/user_profile.dart';
import 'onboarding_form_widgets.dart';
import 'university_picker_sheet.dart';

class StepTwoEducation extends StatefulWidget {
  const StepTwoEducation({
    super.key,
    required this.draft,
    required this.onContinue,
  });

  final EducationDraft draft;
  final VoidCallback onContinue;

  @override
  State<StepTwoEducation> createState() => _StepTwoEducationState();
}

class _StepTwoEducationState extends State<StepTwoEducation> {
  late final TextEditingController _schoolController =
      TextEditingController(text: widget.draft.schoolName ?? '');

  @override
  void dispose() {
    _schoolController.dispose();
    super.dispose();
  }

  void _update(VoidCallback fn) => setState(fn);

  bool get _canContinue {
    final EducationDraft d = widget.draft;
    switch (d.type) {
      case EducationType.university:
        return (d.university ?? '').isNotEmpty &&
            d.stream != null &&
            d.department != null;
      case EducationType.highschool:
        return _schoolController.text.trim().length >= 3 &&
            d.grade != null &&
            (d.grade! <= 10 || d.stream != null);
    }
  }

  Future<void> _pickUniversity() async {
    FocusScope.of(context).unfocus();
    final String? selected = await showUniversityPickerSheet(
      context,
      current: widget.draft.university,
    );
    if (selected != null) {
      _update(() => widget.draft.university = selected);
    }
  }

  void _selectStream(StreamType stream) {
    _update(() {
      widget.draft.stream = stream;
      widget.draft.department = null; // Stream changed — reset department.
    });
  }

  void _selectGrade(int grade) {
    _update(() {
      widget.draft.grade = grade;
      if (grade <= 10) {
        widget.draft.stream = null; // Streams apply from grade 11 only.
      }
    });
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    widget.draft.schoolName = _schoolController.text.trim();
    if (!_canContinue) return;
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final EducationDraft d = widget.draft;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SectionReveal(
            child: _EducationTypeToggle(
              value: d.type,
              onChanged: (EducationType type) => _update(() {
                d.type = type;
                d.department = null; // Branch changed — reset downstream.
              }),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (Widget child, Animation<double> animation) =>
                FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(0, 0.02), end: Offset.zero)
                    .animate(CurvedAnimation(
                        parent: animation, curve: Curves.easeOutCubic)),
                child: child,
              ),
            ),
            child: d.type == EducationType.university
                ? _universityBranch(key: const ValueKey<String>('uni'))
                : _highschoolBranch(key: const ValueKey<String>('hs')),
          ),
          const SizedBox(height: 34),
          SectionReveal(
            delay: 240,
            child: PrimaryButton(
              label: 'Continue',
              onTap: _submit,
              isEnabled: _canContinue,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _universityBranch({Key? key}) {
    final EducationDraft d = widget.draft;
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionReveal(
          delay: 40,
          child:
              _UniversityField(selected: d.university, onTap: _pickUniversity),
        ),
        const SizedBox(height: 16),
        SectionReveal(
          delay: 130,
          child: _StreamSection(stream: d.stream, onSelect: _selectStream),
        ),
        if (d.stream == StreamType.social) ...<Widget>[
          const SizedBox(height: 16),
          SectionReveal(
            delay: 40,
            child: _DepartmentSection(
              department: d.department,
              onSelect: (String value) =>
                  _update(() => d.department = value),
            ),
          ),
        ],
      ],
    );
  }

  Widget _highschoolBranch({Key? key}) {
    final EducationDraft d = widget.draft;
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionReveal(
          delay: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const FieldLabel('School name'),
              const SizedBox(height: 8),
              AppTextField(
                controller: _schoolController,
                hint: 'e.g. Menelik II High School',
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SectionReveal(
          delay: 130,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const FieldLabel('Grade'),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  for (int i = 0; i < 4; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < 3 ? 10 : 0),
                        child: _GradeChip(
                          grade: 9 + i,
                          selected: d.grade == 9 + i,
                          onTap: () => _selectGrade(9 + i),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (d.grade != null && d.grade! >= 11) ...<Widget>[
          const SizedBox(height: 16),
          SectionReveal(
            delay: 40,
            child: _StreamSection(stream: d.stream, onSelect: _selectStream),
          ),
        ],
      ],
    );
  }
}

class _EducationTypeToggle extends StatelessWidget {
  const _EducationTypeToggle({required this.value, required this.onChanged});

  final EducationType value;
  final ValueChanged<EducationType> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double thumbWidth = (constraints.maxWidth - 10) / 2;
        return Container(
          height: 58,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06), width: 1.2),
          ),
          child: Stack(
            children: <Widget>[
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                top: 0,
                bottom: 0,
                left: value == EducationType.university ? 0 : thumbWidth,
                child: Container(
                  width: thumbWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    const LinearGradient(
                            colors: <Color>[AppColors.accentDeep, AppColors.accent])
                        as BoxDecoration,
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _segment(
                      icon: Icons.account_balance_rounded,
                      label: 'University',
                      selected: value == EducationType.university,
                      onTap: () => onChanged(EducationType.university),
                    ),
                  ),
                  Expanded(
                    child: _segment(
                      icon: Icons.menu_book_rounded,
                      label: 'Highschool',
                      selected: value == EducationType.highschool,
                      onTap: () => onChanged(EducationType.highschool),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _segment({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon,
                size: 17, color: selected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UniversityField extends StatelessWidget {
  const _UniversityField({required this.selected, required this.onTap});

  final String? selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = selected != null && selected!.isNotEmpty;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasSelection
                ? AppColors.accent.withOpacity(0.7)
                : Colors.white.withOpacity(0.08),
            width: hasSelection ? 1.5 : 1.2,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.surfaceHigh,
              ),
              child: Icon(
                Icons.account_balance_rounded,
                size: 20,
                color: hasSelection
                    ? AppColors.accentSoft
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'University',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selected ?? 'Select your university',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: hasSelection
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 24, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _GradeChip extends StatelessWidget {
  const _GradeChip({
    required this.grade,
    required this.selected,
    required this.onTap,
  });

  final int grade;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.accent
                : Colors.white.withOpacity(0.08),
            width: selected ? 1.6 : 1.2,
          ),
        ),
        child: Text(
          '$grade',
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _StreamSection extends StatelessWidget {
  const _StreamSection({required this.stream, required this.onSelect});

  final StreamType? stream;
  final ValueChanged<StreamType> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const FieldLabel('Stream'),
        const SizedBox(height: 10),
        SelectionCard(
          icon: Icons.people_alt_rounded,
          title: 'Social Science',
          subtitle: 'Humanities, business and society',
          isSelected: stream == StreamType.social,
          onTap: () => onSelect(StreamType.social),
        ),
        const SizedBox(height: 10),
        SelectionCard(
          icon: Icons.science_rounded,
          title: 'Natural Science',
          subtitle: 'Science, technology and health',
          isSelected: stream == StreamType.natural,
          onTap: () => onSelect(StreamType.natural),
        ),
      ],
    );
  }
}

class _DepartmentSection extends StatelessWidget {
  const _DepartmentSection({required this.department, required this.onSelect});

  final String? department;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const FieldLabel('Department'),
        const SizedBox(height: 10),
        SelectionCard(
          icon: Icons.trending_up_rounded,
          title: 'Economics',
          subtitle: 'Department of Economics',
          isSelected: department == 'economics',
          onTap: () => onSelect('economics'),
        ),
        const SizedBox(height: 10),
        SelectionCard(
          icon: Icons.schedule_rounded,
          title: 'Not decided yet',
          subtitle: 'No department assigned yet',
          isSelected: department == 'none',
          onTap: () => onSelect('none'),
        ),
      ],
    );
  }
}