import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  group('$FirebaseDatabase', () {
    setUp(() async {
      await Firebase.initializeApp();
    });
  });
}
