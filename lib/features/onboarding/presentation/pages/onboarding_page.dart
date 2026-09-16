import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ambient_glow.dart';
import '../../../../core/widgets/simplitor_mark.dart';
import '../../data/profile_repository.dart';
import '../../data/user_profile.dart';
import '../widgets/step_one_personal_info.dart';
import '../widgets/step_three_review.dart';
import '../widgets/step_two_education.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    required this.user,
    required this.onCompleted,
  });

  final User user;
  final VoidCallback onCompleted;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _step = 0;

  late String _name = widget.user.displayName ?? '';
  int? _age;
  String? _phoneDigits;

  final EducationDraft _education = EducationDraft();

  bool _saving = false;
  String? _saveError;

  UserProfile get _profile => UserProfile(
        name: _name,
        age: _age ?? 0,
        phone: '+251${_phoneDigits ?? ''}',
        educationType: _education.type,
        schoolName: _education.schoolName,
        university: _education.university,
        grade: _education.grade,
        stream: _education.stream,
        department: _education.department == 'economics' ? 'economics' : null,
      );

  void _onPersonalContinue(String name, int age, String phoneDigits) {
    setState(() {
      _name = name;
      _age = age;
      _phoneDigits = phoneDigits;
      _step = 1;
    });
  }

  Future<void> _confirmProfile() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });

    try {
      await ProfileRepository.instance
          .saveProfile(widget.user.uid, _profile);
      widget.onCompleted();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveError =
            "We couldn't save your profile. Check your connection and try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: AmbientGlow()),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 14),
                    _buildHeader(),
                    const SizedBox(height: 24),
                    Expanded(child: _buildStep()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _step == 0
                  ? const SizedBox(
                      key: ValueKey<String>('noback'), width: 48, height: 48)
                  : IconButton(
                      key: const ValueKey<String>('back'),
                      onPressed: () => setState(() => _step -= 1),
                      icon: const Icon(Icons.arrow_back_rounded,
                          size: 22, color: AppColors.textSecondary),
                    ),
            ),
            const Spacer(),
            const SimplitorMark(size: 36),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          "Let's collect your information",
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.14),
                borderRadius: BorderRadius.circular(999),
                border:
                    Border.all(color: AppColors.accent.withOpacity(0.4)),
              ),
              child: Text(
                'Step ${_step + 1} of 3',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.accentSoft,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LayoutBuilder(
                builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOutCubic,
                    height: 5,
                    width: constraints.maxWidth * (_step + 1) / 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        colors: <Color>[AppColors.accentDeep, AppColors.accent],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) =>
          FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero)
              .animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
      child: switch (_step) {
        0 => StepOnePersonalInfo(
            key: const ValueKey<int>(0),
            initialName: _name,
            onContinue: _onPersonalContinue,
          ),
        1 => StepTwoEducation(
            key: const ValueKey<int>(1),
            draft: _education,
            onContinue: () => setState(() => _step = 2),
          ),
        _ => StepThreeReview(
            key: const ValueKey<int>(2),
            profile: _profile,
            isLoading: _saving,
            error: _saveError,
            onConfirm: _confirmProfile,
          ),
      },
    );
  }
}