import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/open_link.dart';
import 'onboarding_form_widgets.dart';

class StepOnePersonalInfo extends StatefulWidget {
  const StepOnePersonalInfo({
    super.key,
    required this.initialName,
    required this.onContinue,
  });

  final String initialName;
  final void Function(String name, int age, String phoneDigits) onContinue;

  @override
  State<StepOnePersonalInfo> createState() => _StepOnePersonalInfoState();
}

class _StepOnePersonalInfoState extends State<StepOnePersonalInfo> {
  late final TextEditingController _name =
      TextEditingController(text: widget.initialName);
  late final TextEditingController _age = TextEditingController();
  late final TextEditingController _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool get _nameValid => _name.text.trim().length >= 2;

  bool get _ageValid {
    final int? value = int.tryParse(_age.text.trim());
    return value != null && value >= 10 && value <= 100;
  }

  bool get _phoneValid =>
      _phone.text.length == 9 &&
      (_phone.text.startsWith('9') || _phone.text.startsWith('7'));

  bool get _valid => _nameValid && _ageValid && _phoneValid;

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_valid) return;
    widget.onContinue(
      _name.text.trim(),
      int.parse(_age.text.trim()),
      _phone.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SectionReveal(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const FieldLabel('Full name'),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _name,
                  hint: 'e.g. Abebe Kebede',
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionReveal(
            delay: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const FieldLabel('Age'),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _age,
                  hint: 'e.g. 19',
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  maxLength: 3,
                  textInputAction: TextInputAction.next,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionReveal(
            delay: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const FieldLabel('Phone number'),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                          width: 1.2,
                        ),
                      ),
                      child: const Text(
                        '+251',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentSoft,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppTextField(
                        controller: _phone,
                        hint: '9XX XXX XXX',
                        keyboardType: TextInputType.phone,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        maxLength: 9,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 34),
          SectionReveal(
            delay: 270,
            child: PrimaryButton(
              label: 'Continue',
              onTap: _submit,
              isEnabled: _valid,
            ),
          ),
          const SizedBox(height: 18),
          SectionReveal(
            delay: 330,
            child: Center(
              child: TextButton(
                onPressed: () => openExternalLink('https://google.com'),
                child: const Text(
                  'Need help? Contact us',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentSoft,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}