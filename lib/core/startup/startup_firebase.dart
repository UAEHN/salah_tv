import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

/// Initializes Firebase for both TV and mobile platforms.
Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
