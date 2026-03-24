// =======================================================
// CHAT OPEN
// -------------------------------------------------------
// Tela de conversa (base)
// =======================================================

import 'package:flutter/material.dart';

import '../../../shared/widgets/app_header.dart';

class ChatOpen extends StatelessWidget {
  const ChatOpen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const [

          AppHeader(title: 'Nicolas'),

          Expanded(
            child: Center(
              child: Text('Chat aberto aqui'),
            ),
          ),
        ],
      ),
    );
  }
}