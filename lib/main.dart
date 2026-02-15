import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/transaction.dart';
import 'providers/transaction_provider.dart';
import 'screens/dashboard_screen.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Hive initialization ──────────────────────────────────────
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  await HiveService.openBox();

  runApp(const LedgerFlowApp());
}

class LedgerFlowApp extends StatelessWidget {
  const LedgerFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionProvider()..loadTransactions(),
      child: MaterialApp(
        title: 'LedgerFlow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: const Color(0xFF40E0D0), // Turquoise
          scaffoldBackgroundColor: const Color(0xFF0D0D0D),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF1A1A2E),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
