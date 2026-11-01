import 'package:hive/hive.dart';

abstract class HadithLocalDataSource {
String? getDailyHadithApiUrl();

String? getDailyHadithDate();

Future<void> saveDailyHadith({
required String apiUrl,
required String date,
});
}

class HadithLocalDataSourceImpl implements HadithLocalDataSource {
static const String _apiUrlKey = 'daily_hadith_api_url';
static const String _dateKey = 'daily_hadith_date';

final Box settingsBox;

HadithLocalDataSourceImpl({
required this.settingsBox,
});

@override
String? getDailyHadithApiUrl() {
return settingsBox.get(_apiUrlKey) as String?;
}

@override
String? getDailyHadithDate() {
return settingsBox.get(_dateKey) as String?;
}

@override
Future<void> saveDailyHadith({
required String apiUrl,
required String date,
}) async {
await settingsBox.put(_apiUrlKey, apiUrl);
await settingsBox.put(_dateKey, date);
}
}
