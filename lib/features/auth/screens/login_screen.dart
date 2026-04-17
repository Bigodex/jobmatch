// =======================================================
// LOGIN SCREEN
// -------------------------------------------------------
// - placeholders ajustados
// - ícones AppIcons brancos
// - eyeClosed para controlar obscure
// - Job branco + Match azul
// - typing animation no JobMatch
// - loading com 3 pontinhos em pulse
// - borda azul só no foco
// - margem do voltar reduzida
// - validações inline
// - layout protegido contra keyboard overflow
// =======================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

// =======================================================
// CORE
// =======================================================
import 'package:jobmatch/core/constants/app_icons.dart';

// =======================================================
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;

  bool _obscure = true;

  String? _emailError;
  String? _passwordError;

  static const String _brandText = 'JobMatch';
  int _typedLength = 0;
  Timer? _typingTimer;
  Timer? _cursorTimer;
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();

    _emailFocusNode = FocusNode()..addListener(_onFocusChanged);
    _passwordFocusNode = FocusNode()..addListener(_onFocusChanged);

    _startTypingAnimation();
    _startCursorBlink();
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startTypingAnimation() {
    _typingTimer?.cancel();

    _typingTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (!mounted) return;

      if (_typedLength < _brandText.length) {
        setState(() {
          _typedLength++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startCursorBlink() {
    _cursorTimer?.cancel();

    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;

      setState(() {
        _showCursor = !_showCursor;
      });
    });
  }

  bool _validateFields() {
    final emailValue = email.text.trim();
    final passwordValue = password.text.trim();

    String? emailError;
    String? passwordError;

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (emailValue.isEmpty) {
      emailError = 'Informe seu e-mail de acesso.';
    } else if (!emailRegex.hasMatch(emailValue)) {
      emailError = 'Digite um e-mail válido.';
    }

    if (passwordValue.isEmpty) {
      passwordError = 'Informe sua senha.';
    } else if (passwordValue.length < 6) {
      passwordError = 'A senha deve ter pelo menos 6 caracteres.';
    }

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    return emailError == null && passwordError == null;
  }

  void _handleAuthError(Object error) {
    final message = error.toString().toLowerCase();

    String? emailError;
    String? passwordError;

    if (message.contains('wrong-password') ||
        message.contains('invalid-credential') ||
        message.contains('invalid credential') ||
        message.contains('invalid login credentials')) {
      passwordError = 'Senha incorreta. Tente novamente.';
    } else if (message.contains('user-not-found') ||
        message.contains('no user record')) {
      emailError = 'Não encontramos uma conta com esse e-mail.';
    } else if (message.contains('invalid-email')) {
      emailError = 'Digite um e-mail válido.';
    } else if (message.contains('too-many-requests')) {
      passwordError = 'Muitas tentativas. Tente novamente em instantes.';
    } else {
      passwordError = 'Não foi possível acessar. Confira seus dados.';
    }

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });
  }

  void _submitLogin() {
    FocusScope.of(context).unfocus();

    if (!_validateFields()) return;

    ref.read(authControllerProvider.notifier).login(
          email.text.trim(),
          password.text.trim(),
        );
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _cursorTimer?.cancel();

    _emailFocusNode
      ..removeListener(_onFocusChanged)
      ..dispose();

    _passwordFocusNode
      ..removeListener(_onFocusChanged)
      ..dispose();

    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final authState = ref.watch(authControllerProvider);

    // ===================================================
    // LISTENER
    // ===================================================
    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (e, _) {
          _handleAuthError(e);
        },
        data: (_) {
          context.go('/home');
        },
      );
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // ===================================================
                // BACK BUTTON
                // ===================================================
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 18,
                    onPressed: () => context.go('/welcome'),
                    icon: Icon(
                      Icons.arrow_back,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),

                // ===================================================
                // CONTEÚDO COM EXPANDED
                // ===================================================
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.only(
                      top: 12,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.25),
                                    Colors.white.withOpacity(0.15),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            SvgPicture.asset(
                              'assets/images/jobu_desk.svg',
                              height: 180,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        _buildTypingBrand(
                          theme: theme,
                          primaryColor: colors.primary,
                        ),

                        const SizedBox(height: 32),

                        // ===================================================
                        // INPUT EMAIL DE ACESSO
                        // ===================================================
                        _input(
                          context,
                          iconPath: AppIcons.user,
                          hint: 'Digite seu e-mail de acesso',
                          controller: email,
                          focusNode: _emailFocusNode,
                          errorText: _emailError,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {
                            if (_emailError != null) {
                              setState(() {
                                _emailError = null;
                              });
                            }
                          },
                          onSubmitted: (_) {
                            _passwordFocusNode.requestFocus();
                          },
                        ),

                        const SizedBox(height: 12),

                        // ===================================================
                        // INPUT SENHA
                        // ===================================================
                        _input(
                          context,
                          iconPath: AppIcons.lock,
                          hint: 'Digite sua senha',
                          controller: password,
                          focusNode: _passwordFocusNode,
                          errorText: _passwordError,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          onChanged: (_) {
                            if (_passwordError != null) {
                              setState(() {
                                _passwordError = null;
                              });
                            }
                          },
                          onSubmitted: (_) => _submitLogin(),
                        ),

                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Esqueci minha senha!',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ===================================================
                        // BOTÃO ENTRAR
                        // ===================================================
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: authState.isLoading ? null : _submitLogin,
                            child: authState.isLoading
                                ? const _LoginDotsLoading()
                                : const Text(
                                    'Acessar',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        _socialButton(
                          context,
                          iconPath: AppIcons.google,
                          text: 'Entrar com Google',
                        ),

                        const SizedBox(height: 10),

                        _socialButton(
                          context,
                          iconPath: AppIcons.apple,
                          text: 'Entrar com Apple',
                        ),

                        const SizedBox(height: 32),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Não tem conta? ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color:
                                    theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/onboarding'),
                              child: Text(
                                'Criar conta',
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =======================================================
  // BRAND COM TYPING
  // =======================================================
  Widget _buildTypingBrand({
    required ThemeData theme,
    required Color primaryColor,
  }) {
    final visibleText = _brandText.substring(0, _typedLength);

    String jobPart = '';
    String matchPart = '';

    if (visibleText.length <= 3) {
      jobPart = visibleText;
    } else {
      jobPart = 'Job';
      matchPart = visibleText.substring(3);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
            children: [
              TextSpan(
                text: jobPart,
                style: const TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: matchPart,
                style: TextStyle(color: primaryColor),
              ),
            ],
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: _showCursor ? 1 : 0,
          child: Container(
            margin: const EdgeInsets.only(left: 3, top: 2),
            width: 2,
            height: 24,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  // =======================================================
  // INPUT CUSTOM
  // =======================================================
  Widget _input(
    BuildContext context, {
    required String iconPath,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String? errorText,
    required ValueChanged<String> onChanged,
    required ValueChanged<String> onSubmitted,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    final theme = Theme.of(context);
    final isFocused = focusNode.hasFocus;

    final borderColor = errorText != null
        ? Colors.redAccent
        : isFocused
            ? theme.colorScheme.primary
            : Colors.white.withOpacity(0.12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                iconPath,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  obscureText: isPassword ? _obscure : false,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  cursorColor: theme.colorScheme.primary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                    ),
                  ),
                ),
              ),
              if (isPassword)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                  child: SvgPicture.asset(
                    _obscure ? AppIcons.eyeclosed : AppIcons.eye,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // =======================================================
  // SOCIAL BUTTON
  // =======================================================
  Widget _socialButton(
    BuildContext context, {
    required String iconPath,
    required String text,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================
// LOADING - 3 PONTINHOS COM PULSE
// =======================================================

class _LoginDotsLoading extends StatefulWidget {
  const _LoginDotsLoading();

  @override
  State<_LoginDotsLoading> createState() => _LoginDotsLoadingState();
}

class _LoginDotsLoadingState extends State<_LoginDotsLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _pulseValue(int index) {
    final start = index * 0.18;
    final end = start + 0.42;
    final value = _controller.value;

    if (value < start || value > end) return 0;

    final t = (value - start) / (end - start);

    if (t <= 0.5) {
      return Curves.easeOut.transform(t * 2);
    }

    return Curves.easeIn.transform((1 - t) * 2);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final pulse = _pulseValue(index);
            final opacity = 0.30 + (pulse * 0.70);
            final scale = 0.80 + (pulse * 0.35);

            return Padding(
              padding: EdgeInsets.only(right: index == 2 ? 0 : 6),
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}