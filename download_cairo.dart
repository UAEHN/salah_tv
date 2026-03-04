import 'dart:io';

void main() async {
  final urls = {
    'Cairo-Regular.ttf': 'https://github.com/googlefonts/cairo/raw/main/fonts/ttf/Cairo-Regular.ttf',
    'Cairo-Bold.ttf': 'https://github.com/googlefonts/cairo/raw/main/fonts/ttf/Cairo-Bold.ttf',
    'Cairo-SemiBold.ttf': 'https://github.com/googlefonts/cairo/raw/main/fonts/ttf/Cairo-SemiBold.ttf',
  };

  final client = HttpClient();

  for (final entry in urls.entries) {
    final fileName = entry.key;
    final url = entry.value;
    final file = File('c:/tv_App/salah_tv/assets/fonts/Cairo/$fileName');
    file.parent.createSync(recursive: true);

    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      await response.pipe(file.openWrite());
      print('Font $fileName downloaded successfully.');
    } catch (e) {
      print('Error downloading font $fileName: $e');
    }
  }
  
  client.close();
}
