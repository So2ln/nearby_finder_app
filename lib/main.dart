import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_finder_app/screens/location_search_screen.dart';
import 'firebase_options.dart';

void main() async {
  // runApp 전에 다른 코드 실행하려면 이 라인이 필수라고 한다!
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 앱 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nearby Finder',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: const Color(0xFFffd900), // 레몬색 계열
            ).copyWith(
              onPrimary: const Color(
                0xFF424242,
              ), // 2. onPrimary 색상만 짙은 회색으로 덮어쓰기
            ),
        useMaterial3: true, // Material 3 디자인 사용
      ),
      home: LocationSearchScreen(),
    );
  }
}
