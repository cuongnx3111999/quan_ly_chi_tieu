import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:money_grower/models/user_model.dart';
import 'package:money_grower/ui/budget_screen/budget_screen.dart';
import 'package:money_grower/ui/custom_control/faded_transition.dart';
import 'package:money_grower/ui/debt_screen/debt_screen.dart';
import 'package:money_grower/ui/login_screen/welcome_screen.dart';
import 'package:money_grower/ui/statistics_screen/statistics_screen.dart';
import 'package:money_grower/ui/transaction_screen/transaction_screen.dart';
import '../../helper/current_user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: MoneyGrowerApp()));
}

class MoneyGrowerApp extends StatefulWidget {
  @override
  _MoneyGrowerAppState createState() => _MoneyGrowerAppState();
}

class _MoneyGrowerAppState extends State<MoneyGrowerApp> {
  late Future<bool> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeApp();
  }

  Future<bool> _initializeApp() async {
    if (!CurrentUser.isLoggedIn) {
      await CurrentUser.signOut();
      return false;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(CurrentUser.id)
        .get();

    if (doc.exists) {
      CurrentUser.setUser(UserModel.fromMap(doc.data()!, doc.id));
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen();
        }

        if (snapshot.hasError || !snapshot.data!) {
          return ErrorScreen(
            onRetry: () => setState(() => _initializationFuture = _initializeApp()),
          );
        }
        return MainScreen();
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const ErrorScreen({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Không thể khởi tạo ứng dụng", style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            ElevatedButton(onPressed: onRetry, child: Text("Thử lại")),
            TextButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                  context, FadeRoute(page: WelcomeScreen()), (route) => false),
              child: Text("Quay lại màn hình đăng nhập"),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentScreenIndex = 0;
  final List<String> _menuOptions = ["🚪 Đăng xuất"];

  final List<Widget> _screens = [
    TransactionScreen(),
    DebtScreen(),
    StatisticsScreen(),
    BudgetScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/coins.png', width: 60, height: 60),
            SizedBox(width: 8),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.settings),
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => _menuOptions
                .map((option) => PopupMenuItem<String>(value: option, child: Text(option)))
                .toList(),
          ),
        ],
      ),
      body: _screens[_currentScreenIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentScreenIndex,
        onTap: (index) => setState(() => _currentScreenIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Giao dịch'),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Vay mượn'),
          BottomNavigationBarItem(icon: Icon(Icons.insert_chart), label: 'Thống kê'),
          BottomNavigationBarItem(icon: Icon(Icons.collections_bookmark), label: 'Ngân sách'),
        ],
      ),
    );
  }

  void _handleMenuSelection(String option) async {
if (option == "🚪 Đăng xuất") {
      final result = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Đăng xuất?"),
          content: Text("Bạn có chắc chắn muốn đăng xuất?"),
          actions: [
            TextButton(child: Text("Huỷ"), onPressed: () => Navigator.pop(context, false)),
            TextButton(
              child: Text("Đăng xuất", style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

      if (result == true) {
        await CurrentUser.signOut();
        Navigator.pushAndRemoveUntil(
            context, FadeRoute(page: WelcomeScreen()), (route) => false);
      }
    }
  }
}