import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDkcGQrdvOlq1XFXNPKU05CrD06rWoM0LI",
            authDomain: "h-m-o-app-9y3jk1.firebaseapp.com",
            projectId: "h-m-o-app-9y3jk1",
            storageBucket: "h-m-o-app-9y3jk1.firebasestorage.app",
            messagingSenderId: "121349819635",
            appId: "1:121349819635:web:bfa2d65e7288b0c182fb86"));
  } else {
    await Firebase.initializeApp();
  }
}
