// =======================================================
// REGISTER SCREEN
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // ===================================================
    // LISTENER GLOBAL (ERRO + SUCESSO)
    // ===================================================
    ref.listen(authControllerProvider, (previous, next) {
      
      // ❌ ERRO
      next.whenOrNull(
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        },

        // ✅ SUCESSO → REDIRECIONA
        data: (_) {
          context.go('/home'); // ou '/profile'
        },
      );
    });

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // ===================================================
                // TÍTULO
                // ===================================================
                const Text(
                  'Criar conta',
                  style: TextStyle(
                    fontSize: 28,  
                  ),
                ),

                const SizedBox(height: 32),

                // ===================================================
                // EMAIL
                // ===================================================
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // ===================================================
                // SENHA
                // ===================================================
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                // ===================================================
                // BOTÃO CADASTRO
                // ===================================================
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authState.isLoading
                        ? null
                        : () {
                            ref
                                .read(authControllerProvider.notifier)
                                .register(
                                  email.text.trim(),
                                  password.text.trim(),
                                );
                          },
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Cadastrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}