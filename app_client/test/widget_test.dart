import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tocitech/main.dart';

void main() {
  testWidgets('shows login when there is no saved session', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const TociTechClientApp());
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(find.text('Iniciar sesion'), findsOneWidget);
  });
}
