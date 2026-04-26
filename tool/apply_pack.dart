// ignore_for_file: avoid_print

// =======================================================
// APPLY PACK SCRIPT
// -------------------------------------------------------
// Aplica um pacote ZIP no projeto atual.
//
// O script:
// - lê um ZIP informado no terminal
// - atualiza apenas os arquivos presentes no pacote
// - adiciona arquivos novos caso não existam
// - cria backup antes de sobrescrever arquivos existentes
// - ignora pastas técnicas e arquivos inseguros
//
// Uso:
// dart run tool/apply_pack.dart incoming_packs/nome-do-pack.zip
// =======================================================

import 'dart:io';

import 'package:archive/archive_io.dart';

// =======================================================
// MAIN
// -------------------------------------------------------
// Fluxo principal da automação:
// - valida o argumento recebido
// - abre o ZIP
// - percorre os arquivos internos
// - aplica cada arquivo no projeto
// - exibe resumo final
// =======================================================
void main(List<String> args) {
  if (args.isEmpty) {
    _error('Informe o caminho do pacote ZIP.');
    _usage();
    exit(1);
  }

  final zipPath = args.first;
  final zipFile = File(zipPath);

  if (!zipFile.existsSync()) {
    _error('Arquivo ZIP não encontrado: $zipPath');
    exit(1);
  }

  final projectRoot = Directory.current;
  final backupDir = Directory(
    '${projectRoot.path}/.pack_backups/${DateTime.now().millisecondsSinceEpoch}',
  );

  final bytes = zipFile.readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);

  final zipFiles = archive.files.where((file) => file.isFile).toList();

  if (zipFiles.isEmpty) {
    print('\n⚠️ O pack não possui arquivos aplicáveis.');
    print('Verifique se o ZIP não está vazio ou contém apenas pastas.');
    return;
  }

  var added = 0;
  var updated = 0;
  var skipped = 0;
  var shouldRunPubGet = false;

  print('\nAplicando pack: $zipPath');
  print('Arquivos encontrados no ZIP: ${zipFiles.length}\n');

  for (final file in zipFiles) {
    final relativePath = file.name.replaceAll('\\', '/');

    if (_shouldIgnore(relativePath)) {
      skipped++;
      print('Ignorado: $relativePath');
      continue;
    }

    final targetFile = File('${projectRoot.path}/$relativePath');

    if (!_isSafePath(projectRoot, targetFile)) {
      skipped++;
      print('Bloqueado por segurança: $relativePath');
      continue;
    }

    if (relativePath == 'pubspec.yaml' || relativePath == 'pubspec.lock') {
      shouldRunPubGet = true;
    }

    targetFile.parent.createSync(recursive: true);

    if (targetFile.existsSync()) {
      final backupFile = File('${backupDir.path}/$relativePath');

      backupFile.parent.createSync(recursive: true);
      targetFile.copySync(backupFile.path);

      targetFile.writeAsBytesSync(file.content as List<int>);

      updated++;
      print('Atualizado: $relativePath');
    } else {
      targetFile.writeAsBytesSync(file.content as List<int>);

      added++;
      print('Adicionado: $relativePath');
    }
  }

  print('\nPack aplicado com sucesso.');
  print('Arquivos atualizados: $updated');
  print('Arquivos adicionados: $added');
  print('Arquivos ignorados: $skipped');

  if (updated > 0) {
    print('\nBackup criado em: ${backupDir.path}');
  }

  print('\nAgora rode:');

  if (shouldRunPubGet) {
    print('flutter pub get');
  }

  print('flutter analyze');
}

// =======================================================
// SHOULD IGNORE
// -------------------------------------------------------
// Bloqueia arquivos e pastas que não devem ser aplicados
// no projeto por segurança ou por serem gerados localmente.
// =======================================================
bool _shouldIgnore(String path) {
  final normalizedPath = path.replaceAll('\\', '/');

  final blockedPaths = [
    '.git/',
    '.dart_tool/',
    'build/',
    '.idea/',
    '.vscode/',
    '.pack_backups/',
    'packs/',
    'incoming_packs/',
  ];

  final blockedFiles = [
    '.DS_Store',
  ];

  if (blockedFiles.contains(normalizedPath)) {
    return true;
  }

  return blockedPaths.any(
    (blockedPath) => normalizedPath.startsWith(blockedPath),
  );
}

// =======================================================
// IS SAFE PATH
// -------------------------------------------------------
// Garante que nenhum arquivo do ZIP consiga escapar da
// raiz do projeto usando caminhos como ../../arquivo.
// =======================================================
bool _isSafePath(Directory root, File target) {
  final rootPath = root.absolute.path;
  final targetPath = target.absolute.path;

  return targetPath.startsWith(rootPath);
}

// =======================================================
// USAGE
// -------------------------------------------------------
// Exibe o formato correto de execução do script.
// =======================================================
void _usage() {
  print('\nUso:');
  print('dart run tool/apply_pack.dart incoming_packs/nome-do-pack.zip');
}

// =======================================================
// ERROR
// -------------------------------------------------------
// Exibe mensagens de erro em formato padronizado.
// =======================================================
void _error(String message) {
  print('Erro: $message');
}
