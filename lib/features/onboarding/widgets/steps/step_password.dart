// =======================================================
// STEP PASSWORD / ACCOUNT
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/onboarding/providers/onboarding_provider.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';
import 'package:jobmatch/shared/widgets/app_validated_input_field.dart';

class StepPassword extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final Function(String?) onJobuMessageChange;

  const StepPassword({
    super.key,
    required this.onNext,
    required this.onJobuMessageChange,
  });

  @override
  ConsumerState<StepPassword> createState() => _StepPasswordState();
}

class _StepPasswordState extends ConsumerState<StepPassword> {
  late final TextEditingController email;
  late final TextEditingController password;
  late final TextEditingController confirmPassword;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _emailHasError = false;
  bool _passwordHasError = false;
  bool _confirmPasswordHasError = false;

  @override
  void initState() {
    super.initState();

    final data = ref.read(onboardingProvider);

    email = TextEditingController(text: data.email ?? '');
    password = TextEditingController(text: data.password ?? '');
    confirmPassword = TextEditingController(text: data.password ?? '');
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(value.trim());
  }

  bool _hasMinPasswordLength(String value) {
    return value.trim().length >= 6;
  }

  bool get _isEmailValid {
    final value = email.text.trim();
    if (value.isEmpty) return false;
    return _isValidEmail(value);
  }

  bool get _isPasswordValid {
    final value = password.text.trim();
    if (value.isEmpty) return false;
    return _hasMinPasswordLength(value);
  }

  bool get _isConfirmPasswordValid {
    final passwordValue = password.text.trim();
    final confirmValue = confirmPassword.text.trim();

    if (confirmValue.isEmpty) return false;
    if (!_hasMinPasswordLength(passwordValue)) return false;

    return passwordValue == confirmValue;
  }

  void _validateAndProceed() {
    final emailValue = email.text.trim();
    final passwordValue = password.text.trim();
    final confirmValue = confirmPassword.text.trim();

    setState(() {
      _emailHasError = emailValue.isEmpty || !_isValidEmail(emailValue);
      _passwordHasError =
          passwordValue.isEmpty || !_hasMinPasswordLength(passwordValue);
      _confirmPasswordHasError = confirmValue.isEmpty ||
          !_hasMinPasswordLength(passwordValue) ||
          passwordValue != confirmValue;
    });

    if (emailValue.isEmpty) {
      widget.onJobuMessageChange(
        'Ei 👀 preencha seu e-mail para continuar.',
      );
      return;
    }

    if (!_isValidEmail(emailValue)) {
      widget.onJobuMessageChange(
        'Hum… esse e-mail não parece válido.',
      );
      return;
    }

    if (passwordValue.isEmpty) {
      widget.onJobuMessageChange(
        'Você precisa criar uma senha para entrar.',
      );
      return;
    }

    if (!_hasMinPasswordLength(passwordValue)) {
      widget.onJobuMessageChange(
        'Sua senha precisa ter pelo menos 6 caracteres.',
      );
      return;
    }

    if (confirmValue.isEmpty) {
      widget.onJobuMessageChange(
        'Confirme sua senha para eu ter certeza.',
      );
      return;
    }

    if (passwordValue != confirmValue) {
      widget.onJobuMessageChange(
        'As senhas não coincidem. Confere e tenta de novo.',
      );
      return;
    }

    widget.onJobuMessageChange(null);

    ref.read(onboardingProvider.notifier).setAccount(
          email: emailValue,
          password: passwordValue,
        );

    widget.onNext();
  }

  Widget _buildPasswordSuffix({
    required bool obscure,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: SvgPicture.asset(
          obscure ? AppIcons.eyeclosed : AppIcons.eye,
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(
            theme.colorScheme.onSurface.withOpacity(0.6),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          AppSectionCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.cardTertiary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.puzzle,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Dados de Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      color: Colors.white.withOpacity(0.08),
                      height: 1,
                    ),
                    const SizedBox(height: 16),

                    _editItem(
                      icon: AppIcons.mail,
                      title: 'Email',
                      child: AppValidatedInputField(
                        controller: email,
                        hint: 'Digite seu email',
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        hasError: _emailHasError,
                        isValid: _isEmailValid,
                        onChanged: (_) {
                          setState(() {
                            if (_emailHasError) {
                              _emailHasError = !_isEmailValid;
                            }
                          });
                          widget.onJobuMessageChange(null);
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    _editItem(
                      icon: AppIcons.lock,
                      title: 'Senha',
                      child: AppValidatedInputField(
                        controller: password,
                        hint: 'Crie uma senha',
                        obscureText: _obscurePassword,
                        autofillHints: const [AutofillHints.newPassword],
                        hasError: _passwordHasError,
                        isValid: _isPasswordValid,
                        trailing: _buildPasswordSuffix(
                          obscure: _obscurePassword,
                          onTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        onChanged: (_) {
                          setState(() {
                            if (_passwordHasError) {
                              _passwordHasError = !_isPasswordValid;
                            }

                            if (_confirmPasswordHasError ||
                                confirmPassword.text.isNotEmpty) {
                              _confirmPasswordHasError =
                                  !_isConfirmPasswordValid &&
                                      confirmPassword.text.trim().isNotEmpty;
                            }
                          });

                          widget.onJobuMessageChange(null);
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    _editItem(
                      icon: AppIcons.lock,
                      title: 'Confirmar senha',
                      child: AppValidatedInputField(
                        controller: confirmPassword,
                        hint: 'Digite sua senha novamente',
                        obscureText: _obscureConfirmPassword,
                        autofillHints: const [AutofillHints.password],
                        hasError: _confirmPasswordHasError,
                        isValid: _isConfirmPasswordValid,
                        trailing: _buildPasswordSuffix(
                          obscure: _obscureConfirmPassword,
                          onTap: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        onChanged: (_) {
                          setState(() {
                            if (_confirmPasswordHasError) {
                              _confirmPasswordHasError =
                                  !_isConfirmPasswordValid;
                            }
                          });
                          widget.onJobuMessageChange(null);
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _validateAndProceed,
                        child: const Text('Continuar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editItem({
    required String icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(icon, width: 16, height: 16),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: child),
      ],
    );
  }
}