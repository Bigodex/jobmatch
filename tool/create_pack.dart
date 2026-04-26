// =======================================================
// CREATE PACK SCRIPT
// -------------------------------------------------------
// Gera um arquivo ZIP contendo apenas os arquivos alterados
// no projeto local, usando o Git como detector de mudanças.
//
// Uso:
// dart run tool/create_pack.dart
// =======================================================

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

// =======================================================
// MAIN
// -------------------------------------------------------
// Fluxo principal:
// - lê arquivos alterados via git status
// - filtra arquivos ignorados
// - adiciona arquivos válidos no ZIP
// - salva o pack dentro da pasta /packs
// =======================================================
void main() async {
  print('\n🔍 Detectando arquivos alterados via Git...\n');

  final result = await Process.run('git', ['status', '--porcelain']);

  if (result.exitCode != 0) {
    print('❌ Erro ao executar git.');
    print(result.stderr);
    exit(1);
  }

  final lines = LineSplitter.split(result.stdout as String).toList();

  if (lines.isEmpty) {
    print('⚠️ Nenhuma alteração detectada.');
    return;
  }

  final files = <String>[];

  for (final line in lines) {
    if (line.length < 4) continue;

    final filePath = line.substring(3).trim();

    if (_shouldIgnore(filePath)) continue;

    final file = File(filePath);

    if (file.existsSync()) {
      files.add(filePath);
    }
  }

  if (files.isEmpty) {
    print('⚠️ Nenhum arquivo válido para pack.');
    return;
  }

  print('📦 Arquivos incluídos no pack:\n');

  for (final file in files) {
    print('- $file');
  }

  final archive = Archive();

  for (final path in files) {
    final file = File(path);
    final bytes = file.readAsBytesSync();

    archive.addFile(
      ArchiveFile(path, bytes.length, bytes),
    );
  }

  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final packName = 'jobmatch-pack-$timestamp.zip';

  final outputDir = Directory('packs');

  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  final zipEncoder = ZipEncoder();
  final zipData = zipEncoder.encode(archive);

  final outputFile = File('${outputDir.path}/$packName');

  outputFile.writeAsBytesSync(zipData);

  print('\n✅ Pack criado com sucesso!');
  print('📁 Caminho: ${outputFile.path}');
}

// =======================================================
// SHOULD IGNORE
// -------------------------------------------------------
// Evita colocar no pack arquivos/pastas que não devem ser
// versionados ou transportados entre projetos.
// =======================================================
bool _shouldIgnore(String path) {
  final normalizedPath = path.replaceAll('\\', '/');

  final ignoredPaths = [
    '.git/',
    '.dart_tool/',
    'build/',
    '.idea/',
    '.vscode/',
    'packs/',
    '.pack_backups/',
  ];

  final ignoredFiles = [
    '.DS_Store',
  ];

  if (ignoredFiles.contains(normalizedPath)) {
    return true;
  }

  return ignoredPaths.any(
    (ignoredPath) => normalizedPath.startsWith(ignoredPath),
  );
}