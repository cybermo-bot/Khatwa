// Checks every Learn video with YouTube's oEmbed endpoint and updates
// lib/data/learn_videos.dart: a 200 answer marks the video verified and
// records its real title and channel; anything else marks it not verified.
//
// Run from the project root, on a network that reaches YouTube:
//   dart run tool/verify_videos.dart
import 'dart:convert';
import 'dart:io';

final _entry = RegExp(
    r"LearnVideo\('([\w-]{11})', '(\w+)',\s*title: '((?:[^'\\]|\\.)*)', channel: '((?:[^'\\]|\\.)*)'(?:, verified: (?:true|false))?\)");

String _quote(String s) => s.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll(r'$', r'\$');

Future<void> main() async {
  final file = File('lib/data/learn_videos.dart');
  var source = file.readAsStringSync();
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  var ok = 0, failed = 0;
  final replacements = <String, String>{};
  for (final m in _entry.allMatches(source)) {
    final id = m.group(1)!, lang = m.group(2)!;
    final url = Uri.parse('https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=$id&format=json');
    try {
      final res = await (await client.getUrl(url)).close();
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode == 200) {
        final json = jsonDecode(body) as Map<String, dynamic>;
        final title = '${json['title']}', channel = '${json['author_name']}';
        replacements[m.group(0)!] =
            "LearnVideo('$id', '$lang', title: '${_quote(title)}', channel: '${_quote(channel)}', verified: true)";
        stdout.writeln('OK   $id  $channel  |  $title');
        ok++;
      } else {
        replacements[m.group(0)!] =
            "LearnVideo('$id', '$lang', title: '${m.group(3)}', channel: '${m.group(4)}', verified: false)";
        stdout.writeln('FAIL $id  HTTP ${res.statusCode} (missing, private or not embeddable)');
        failed++;
      }
    } catch (e) {
      stdout.writeln('FAIL $id  $e');
      failed++;
    }
  }
  client.close();
  replacements.forEach((from, to) => source = source.replaceFirst(from, to));
  file.writeAsStringSync(source);
  stdout.writeln('\n$ok verified, $failed not. Review each title and channel above before the demo.');
  exit(failed == 0 ? 0 : 1);
}
