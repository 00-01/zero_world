// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:zero_world/app.dart';
import 'package:zero_world/models/listing.dart';
import 'package:zero_world/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home screen shows listings from API', (WidgetTester tester) async {
    final fakeApi = _FakeApiService();

    await tester.pumpWidget(ZeroWorldApp(apiService: fakeApi));

    // Initial frame to mount the widget tree.
    await tester.pump();
    // Allow the post-frame callback to trigger the load.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('zero_world'), findsOneWidget);
    expect(find.text('Listings'), findsOneWidget);
    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);

    expect(find.text(fakeApi.sampleListing.title), findsOneWidget);
    expect(find.textContaining(fakeApi.sampleListing.description.split(' ').first), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
  });
}

class _FakeApiService extends ApiService {
  _FakeApiService()
      : sampleListing = Listing(
          id: 'listing-1',
          title: 'Reusable Water Bottle',
          description: 'Stainless steel bottle in great condition.',
          price: 12.5,
          ownerId: 'user-123',
          isActive: true,
          createdAt: DateTime.now(),
          category: 'Home',
          location: 'Seattle, WA',
          imageUrls: const [],
        );

  final Listing sampleListing;

  @override
  Future<List<Listing>> fetchListings({int limit = 50}) async {
    return [sampleListing];
  }
}
