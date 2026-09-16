import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/user_profile.dart';
import 'onboarding_form_widgets.dart';

class StepThreeReview extends StatelessWidget {
  const StepThreeReview({
    super.key,
    required this.profile,
    required this.isLoading,
    required this.error,
    required this.onConfirm,
  });

  final UserProfile profile;
  final bool isLoading;
  final String? error;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final bool isUniversity =
        profile.educationType == EducationType.university;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SectionReveal(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  'Almost done!',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                SizedBox(height: 8),
                Text(
                  'Check your details — you can go back and change anything '
                  'before we create your profile.',
                  style: TextStyle(
                      fontSize: 14,
                      height: 1.55,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionReveal(
            delay: 80,
            child: _ReviewCard(
              icon: Icons.person_rounded,
              title: 'Personal information',
              rows: <_ReviewRow>[
                _ReviewRow('Full name', profile.name),
                _ReviewRow('Age', '${profile.age} years'),
                _ReviewRow('Phone', profile.phone),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionReveal(
            delay: 160,
            child: _ReviewCard(
              icon: Icons.school_rounded,
              title: 'Education',
              rows: <_ReviewRow>[
                _ReviewRow('Level',
                    isUniversity ? 'University student' : 'Highschool student'),
                _ReviewRow(
                    isUniversity ? 'University' : 'School',
                    isUniversity
                        ? (profile.university ?? '—')
                        : (profile.schoolName ?? '—')),
                if (!isUniversity)
                  _ReviewRow('Grade', 'Grade ${profile.grade ?? '—'}'),
                if (profile.stream != null)
                  _ReviewRow(
                      'Stream',
                      profile.stream == StreamType.social
                          ? 'Social Science'
                          : 'Natural Science'),
                if (isUniversity && profile.stream == StreamType.social)
                  _ReviewRow(
                      'Department',
                      profile.department == 'economics'
                          ? 'Economics'
                          : 'Not decided yet'),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SectionReveal(
            delay: 240,
            child: PrimaryButton(
              label: 'Create profile',
              onTap: onConfirm,
              isEnabled: !isLoading,
              isLoading: isLoading,
            ),
          ),
          const SizedBox(height: 16),
          SectionReveal(delay: 300, child: ErrorBox(message: error)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ReviewRow {
  const _ReviewRow(this.label, this.value);

  final String label;
  final String value;
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.icon,
    required this.title,
    required this.rows,
  });

  final IconData icon;
  final String title;
  final List<_ReviewRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  color: AppColors.surfaceHigh,
                ),
                child: Icon(icon, size: 18, color: AppColors.accentSoft),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < rows.length; i++) ...<Widget>[
            if (i > 0) ...<Widget>[
              Container(height: 1, color: Colors.white.withOpacity(0.05)),
              const SizedBox(height: 14),
            ],
            Text(
              rows[i].label,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              rows[i].value,
              style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
            if (i < rows.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}