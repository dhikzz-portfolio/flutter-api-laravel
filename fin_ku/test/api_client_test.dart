import 'package:flutter_test/flutter_test.dart';
import 'package:fin_ku/core/network/api_client.dart';

void main() {
  test('ApiClient class and methods are available', () {
    expect(ApiClient.uri('/test').path, contains('test'));
  });
}
