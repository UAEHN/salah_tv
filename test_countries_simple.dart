import 'dart:io';

// Paste the kCountries definitions inline (keys and cities)
final kCountries = {
  'UAE': [
    'Abu Dhabi',
    'Ajman',
    'Al Ain',
    'Al Dhaid',
    'Dibba Al-Fujairah',
    'Dubai',
    'Fujairah',
    'Hatta',
    'Kalba',
    'Khor Fakkan',
    'Madinat Zayed',
    'Ras Al Khaimah',
    'Ruwais',
    'Sharjah',
    'Umm Al Quwain',
  ],
  'Oman': [
    'Muscat',
    'Salalah',
    'Sohar',
    'Nizwa',
    'Ibri',
    'Al Buraimi',
    'Al Rustaq',
    'Ibra',
    'Al Seeb',
    'Bousher',
    'Al Suwaiq',
    'Al Khabourah',
    'Shinas',
    'Sahm',
    'Izki',
    'Adam',
    'Sinaw',
    'Khasab',
    'Badbd',
    'Al Qabil',
    'Bayt Al Awabi',
    'Yanqul',
  ],
  'Saudi': [
    'Riyadh',
    'Jeddah',
    'Mecca',
    'Medina',
    'Dammam',
    'Tabuk',
    'Abha',
    'Hail',
    'Najran',
    'Jizan',
    'Al Qassim',
    'Yanbu',
    'Al Kharj',
    'Hafr Al Batin',
    'Qatif',
    'Al Rass',
    'Rabigh',
    'Afif',
    'Ad Dawadimi',
    'Bisha',
    'Samitah',
    'Tanumah',
    'Al Khafji',
    'Thuwal',
    'Rahimah',
    'Al Badr',
    'Safaniyah',
    'Al Ghat',
    'Yanbu Al Sinaiyah',
  ],
  'Kuwait': [
    'Kuwait City',
    'Hawalli',
    'Al Farwaniya',
    'Al Salmiya',
    'Al Ahmadi',
    'Al Jahra',
    'Sabah Al Salem',
    'Al Fahaheel',
    'Al Fintas',
    'Al Manqaf',
    'Al Mahboula',
    'Salwa',
    'Bayan',
    'Al Riqqa',
    'Al Shamiya',
    'Al Funaitees',
    'Al Wafra',
    'Al Zour',
    'Al Dasma',
    'Al Sulaibekhat',
  ],
  'Qatar': [
    'Doha',
    'Al Wakrah',
    'Al Khor',
    'Dukhan',
    'Um Salal Muhammad',
    'Al Wakra North',
    'Um Baab',
    'Al Ghuwairiyah',
    'Al Jumayliyah',
    'Al Fuwairit',
    'Abu Samra',
    'Al Kharrara',
  ],
  'Bahrain': [
    'Manama',
    'Muharraq',
    'Sitra',
    'Jid Haffs',
    'Al Hadd',
    'Dar Kulaib',
    'Al Rifaa',
    'Al Malakiyah',
    'Shahrakkan',
  ],
  'Egypt': [
    'Cairo',
    'Alexandria',
    'Giza',
    'Luxor',
    'Aswan',
    'Tanta',
    'Mansoura',
    'Zagazig',
    'Port Said',
    'Suez',
    'Ismailia',
    'Fayoum',
    'Minya',
    'Assiut',
    'Sohag',
    'Qena',
  ],
  'Iraq': [
    'Baghdad',
    'Basra',
    'Mosul',
    'Erbil',
    'Sulaymaniyah',
    'Kirkuk',
    'Najaf',
    'Karbala',
    'Al-Hillah',
    'Al-Nasiriyah',
    'Al-Kut',
    'Al-Amara',
    'Al-Diwaniyah',
    'Al-Samawah',
    'Al-Ramadi',
    'Al-Fallujah',
    'Tikrit',
    'Baqubah',
    'Dohuk',
    'Al-Faw',
  ],
  'Jordan': [
    'Amman',
    'Irbid',
    'Zarqa',
    'Aqaba',
    'Salt',
    'Madaba',
    'Karak',
    'Jerash',
    'Ajloun',
    'Al Mafraq',
    'Al Tafila',
    'Petra',
  ],
  'Lebanon': [
    'Beirut',
    'Tripoli',
    'Sidon',
    'Tyre',
    'Baalbek',
    'Jounieh',
    'Zahle',
    'Jbeil',
    'Nabatiyeh',
  ],
  'Morocco': [
    'Casablanca',
    'Rabat',
    'Marrakech',
    'Fez',
    'Tangier',
    'Agadir',
    'Meknes',
    'Oujda',
    'Kenitra',
    'Tetouan',
  ],
  'Palestine': [
    'Jerusalem',
    'Gaza',
    'Ramallah',
    'Nablus',
    'Hebron',
    'Jenin',
    'Tulkarem',
    'Jericho',
    'Haifa',
    'Nazareth',
  ],
  'Syria': [
    'Damascus',
    'Aleppo',
    'Homs',
    'Hama',
    'Latakia',
    'Deir ez-Zor',
    'Idlib',
    'Tartus',
    'Al-Hasakah',
  ],
  'Tunisia': [
    'Tunis',
    'Sfax',
    'Sousse',
    'Kairouan',
    'Bizerte',
    'Gabès',
    'Gafsa',
    'Sousse',
    'Monastir',
    'Béja',
  ],
  'Yemen': [
    'Sanaa',
    'Aden',
    'Taiz',
    'Al Hudaydah',
    'Ibb',
    'Dhamar',
    'Al Mukalla',
    'Amran',
  ],
};

void main() {
  final dir = Directory('assets/csv');
  final csvFiles = dir
      .listSync()
      .whereType<File>()
      .where(
        (f) =>
            f.path.replaceAll('\\', '/').endsWith('.csv') &&
            f.path.contains('2026'),
      )
      .toList();

  final allCsvCities = <String>{};

  for (final file in csvFiles) {
    final lines = file.readAsLinesSync();
    if (lines.isEmpty) continue;
    if (!lines[0].toLowerCase().startsWith('city,')) continue;

    for (var i = 1; i < lines.length; i++) {
      final parts = lines[i].split(',');
      if (parts.length >= 8 && parts[0].trim().isNotEmpty) {
        allCsvCities.add(parts[0].trim());
      }
    }
  }

  print('✅ Total unique cities in CSV files: ${allCsvCities.length}');
  print('');

  for (final entry in kCountries.entries) {
    final matched = allCsvCities.where((c) => entry.value.contains(c)).length;
    final status = matched > 0 ? '✅' : '❌ MISSING';
    print(
      '$status  ${entry.key}: $matched/${entry.value.length} cities matched',
    );
  }
}
