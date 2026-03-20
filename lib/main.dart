import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gc_employee_app/theme/app_theme.dart';
import 'package:gc_employee_app/theme/app_colors.dart';
import 'package:gc_employee_app/widgets/app_bottom_nav.dart';

import 'package:gc_employee_app/screens/home_dashboard_screen.dart';
import 'package:gc_employee_app/screens/travel_budget_screen.dart';
import 'package:gc_employee_app/screens/travel_request_screen.dart';
import 'package:gc_employee_app/screens/expense_submission_screen.dart';
import 'package:gc_employee_app/screens/my_devices_screen.dart';
import 'package:gc_employee_app/screens/it_support_screen.dart';
import 'package:gc_employee_app/screens/employee_profile_screen.dart';
import 'package:gc_employee_app/screens/communications_screen.dart';
import 'package:gc_employee_app/screens/manager_approval_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const GcEmployeeApp());
}

// ─────────────────────────────────────────────────────────────────────────────
//  Root application widget
// ─────────────────────────────────────────────────────────────────────────────
class GcEmployeeApp extends StatelessWidget {
  const GcEmployeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GC Employee',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppShell(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  App shell — hosts the bottom nav and the five tab bodies
// ─────────────────────────────────────────────────────────────────────────────
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  void _setTab(int i) => setState(() => _tab = i);

  /// Push a full-screen route over the shell with a slide+fade transition.
  void _push(Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          final slide = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

          final fade = Tween<double>(begin: 0.85, end: 1.0).animate(animation);

          return SlideTransition(
            position: slide,
            child: FadeTransition(opacity: fade, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 380),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  Tab bodies — kept alive with IndexedStack
  // ---------------------------------------------------------------------------
  late final List<Widget> _tabs = [
    // 0 – Home Dashboard
    HomeDashboardScreen(
      onNavigateToProfile: () => _push(const EmployeeProfileScreen()),
      onNavigateToLeave: () => _push(const EmployeeProfileScreen()),
      onNavigateToTravel: () => _setTab(1),
      onNavigateToExpenses: () => _setTab(2),
      onNavigateToTickets: () => _setTab(4),
      onNavigateToApprovals: () => _push(const ManagerApprovalScreen()),
      onNavigateToAnnouncements: () => _push(const CommunicationsScreen()),
    ),

    // 1 – Travel Budget (with FAB to open Travel Request wizard)
    TravelBudgetScreen(
      onSubmitRequest: () => _push(const TravelRequestScreen()),
    ),

    // 2 – Expense Submission
    const ExpenseSubmissionScreen(),

    // 3 – My Devices
    const MyDevicesScreen(),

    // 4 – IT Support (includes ticket submission + history)
    const ItSupportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _tab,
        children: _tabs,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _tab,
        onTap: _setTab,
      ),
    );
  }
}
