import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:disha_makeover/main.dart';
import 'package:disha_makeover/services/storage_service.dart';
import 'package:disha_makeover/services/firebase_service.dart';
import 'package:disha_makeover/state/app_state.dart';

void main() {
  testWidgets('Disha Makeover App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.init();
    final firebaseService = FirebaseService.fromStorage(storageService);
    final appState = AppState(
      storageService: storageService,
      firebaseService: firebaseService,
    );

    await tester.pumpWidget(DishaMakeoverApp(appState: appState));
    await tester.pumpAndSettle();

    expect(find.textContaining('DISHA MAKEOVER'), findsWidgets);
  });
}
