import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:hyper_ui/firebase_options.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hyper_ui/service/main_storage_service/main_storage.dart';

Future initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    //run > flutterfire configure
    //and import DefaultFirebaseOptions!
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.wait();
  if (!kIsWeb) {
    var path = await getTemporaryDirectory();
    Hive.init(path.path);
  }
  mainStorage = await Hive.openBox('mainStorage');
}

extension FirebaseAuthExtension on FirebaseAuth {
  wait() async {
    bool ready = false;
    FirebaseAuth.instance.authStateChanges().listen((event) {
      ready = true;
    });

    while (ready == false) {
      await Future.delayed(const Duration(milliseconds: 250));
    }
  }
}
