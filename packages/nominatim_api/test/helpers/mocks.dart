import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {
  MockHttpClient();
}

class MockResponse extends Mock implements http.Response {
  MockResponse();
}

class FakeUri extends Fake implements Uri {
  FakeUri();
}
