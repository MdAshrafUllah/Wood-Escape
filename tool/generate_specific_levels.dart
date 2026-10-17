import 'dart:convert';
import 'dart:io';

import 'package:woodescape/domain/engine/level_generator.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print(
      'Please provide start and end index for the failed_levels.json array.',
    );
    return;
  }

  final startIndex = int.parse(args[0]);
  final endIndex = int.parse(args[1]);

  final failedLevelsFile = File('failed_levels.json');
  if (!failedLevelsFile.existsSync()) {
    print('❌ failed_levels.json not found!');
    return;
  }

  final List<dynamic> allFailed = jsonDecode(
    failedLevelsFile.readAsStringSync(),
  );
  final targetLevels = allFailed
      .sublist(startIndex, endIndex)
      .map((e) => e as int)
      .toList();

  print(
    '⚙️ Generating ${targetLevels.length} specific levels (Index: $startIndex to $endIndex)...',
  );

  final outputDir = Directory('assets/levels');
  if (!outputDir.existsSync()) outputDir.createSync(recursive: true);

  final Map<int, Map<String, dynamic>> groupedByChunk = {};

  for (int i = 0; i < targetLevels.length; i++) {
    final level = targetLevels[i];

    // প্রতিটি লেভেল জেনারেট করার আগে মেমরি ক্লিয়ার করা হচ্ছে যাতে নতুন ইউনিক পাজল পাওয়া যায়
    LevelGenerator.clearCacheForTest();

    // generateInternal কল করে নতুন লেভেল বানানো হচ্ছে (যেহেতু clear করেছি, নতুন করে চেষ্টা করবে)
    final generated = LevelGenerator.generate(level);

    final chunkStart = ((level - 1) ~/ 1000) * 1000 + 1;
    groupedByChunk.putIfAbsent(chunkStart, () => {});

    groupedByChunk[chunkStart]!['$level'] = {
      'exitSide': generated.exitSide.name,
      'minMoves': generated.minMoves,
      'blocks': generated.blocks
          .map(
            (b) => {
              'id': b.id,
              'isTarget': b.isTarget,
              'orientation': b.orientation.name,
              'length': b.length,
              'row': b.row,
              'col': b.col,
            },
          )
          .toList(),
    };

    if ((i + 1) % 50 == 0) {
      print('Generated ${i + 1}/${targetLevels.length} levels...');
    }
  }

  // চাঙ্ক ফাইলে ডাটা সেভ করা
  for (final entry in groupedByChunk.entries) {
    final chunkStart = entry.key;
    final chunkEnd = chunkStart + 999;
    final fileName = 'levels_${chunkStart}_$chunkEnd.json';
    final file = File('${outputDir.path}/$fileName');

    Map<String, dynamic> existing = {};
    if (file.existsSync()) {
      try {
        existing = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      } catch (_) {}
    }

    existing.addAll(entry.value); // পুরোনো ডাটার ওপর নতুন ডাটা ওভাররাইট হবে
    await file.writeAsString(jsonEncode(existing));
    print('💾 Updated ${entry.key} with ${entry.value.length} new levels');
  }

  print('✅ Done generating $startIndex to $endIndex');
}
