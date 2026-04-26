// =======================================================
// APP LOGGER
// -------------------------------------------------------
// Logger central do app.
//
// Objetivo:
// - evitar uso direto de print()
// - manter logs apenas em ambiente de desenvolvimento
// - impedir vazamento de dados sensíveis em produção
// - padronizar logs de debug, info, warning e error
// =======================================================

import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

// =======================================================
// APP LOGGER
// -------------------------------------------------------
// Classe utilitária estática para logs controlados.
//
// Em release mode, nenhum log é emitido.
// =======================================================
class AppLogger {
  const AppLogger._();

  // ===================================================
  // DEBUG
  // ---------------------------------------------------
  // Usado para eventos técnicos úteis durante desenvolvimento.
  // ===================================================
  static void debug(
    String message, {
    String name = 'JobMatch',
  }) {
    if (!kDebugMode) return;

    developer.log(
      message,
      name: name,
      level: 500,
    );
  }

  // ===================================================
  // INFO
  // ---------------------------------------------------
  // Usado para eventos esperados do fluxo da aplicação.
  // ===================================================
  static void info(
    String message, {
    String name = 'JobMatch',
  }) {
    if (!kDebugMode) return;

    developer.log(
      message,
      name: name,
      level: 800,
    );
  }

  // ===================================================
  // WARNING
  // ---------------------------------------------------
  // Usado para situações não críticas, mas que merecem
  // atenção durante desenvolvimento.
  // ===================================================
  static void warning(
    String message, {
    String name = 'JobMatch',
  }) {
    if (!kDebugMode) return;

    developer.log(
      message,
      name: name,
      level: 900,
    );
  }

  // ===================================================
  // ERROR
  // ---------------------------------------------------
  // Usado para falhas capturadas em services/providers.
  //
  // Não deve receber dados sensíveis no message.
  // ===================================================
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String name = 'JobMatch',
  }) {
    if (!kDebugMode) return;

    developer.log(
      message,
      name: name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
