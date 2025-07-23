import 'package:flutter_test/flutter_test.dart';
import 'package:g_weather_forecast/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
  });

  testWidgets('Ứng dụng khởi động và hiển thị Ho Chi Minh', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(prefs: mockPrefs));
    await tester.pumpAndSettle();

    expect(find.text('Ho Chi Minh, Vietnam'), findsOneWidget);
    expect(find.textContaining('°C'), findsOneWidget);
  });
}
