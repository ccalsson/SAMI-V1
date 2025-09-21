import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../screens/two_factor_setup_screen.dart';
import '../../screens/professional_onboarding_screen.dart';
import '../../screens/privacy_policy_screen.dart';
import '../../screens/billing_history_screen.dart';
import '../../screens/plan_upgrade_screen.dart';

// Importar pantallas (se crearán después)
// import '../modules/bienestar/screens/bienestar_screen.dart';
// import '../modules/tda_tdh/screens/tda_tdh_screen.dart';
// import '../modules/estudiantil/screens/estudiantil_screen.dart';
// import '../modules/desarrollo_profesional/screens/desarrollo_profesional_screen.dart';
// import '../modules/profesionales/screens/profesionales_screen.dart';
// import '../modules/profesionales/screens/profesional_detail_screen.dart';
// import '../modules/profesionales/screens/booking_screen.dart';
// import '../core/billing/screens/paywall_screen.dart';
// import '../core/auth/screens/settings_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String bienestar = '/bienestar';
  static const String tdaTdh = '/tda-tdah';
  static const String estudiantil = '/estudiantil';
  static const String desarrolloProfesional = '/profesional';
  static const String profesionales = '/profesionales';
  static const String profesionalDetail = '/profesionales/:id';
  static const String booking = '/booking/:id';
  static const String paywall = '/paywall';
  static const String settings = '/settings';

  static GoRouter get router => GoRouter(
        initialLocation: home,
        routes: [
          GoRoute(
            path: home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: bienestar,
            builder: (context, state) => const BienestarScreen(),
          ),
          GoRoute(
            path: tdaTdh,
            builder: (context, state) => const TdaTdhScreen(),
          ),
          GoRoute(
            path: estudiantil,
            builder: (context, state) => const EstudiantilScreen(),
          ),
          GoRoute(
            path: desarrolloProfesional,
            builder: (context, state) => const DesarrolloProfesionalScreen(),
          ),
          GoRoute(
            path: profesionales,
            builder: (context, state) => const ProfesionalesScreen(),
          ),
          GoRoute(
            path: profesionalDetail,
            builder: (context, state) {
              final professionalId = state.pathParameters['id']!;
              return ProfesionalDetailScreen(professionalId: professionalId);
            },
          ),
          GoRoute(
            path: booking,
            builder: (context, state) {
              final bookingId = state.pathParameters['id']!;
              return BookingScreen(bookingId: bookingId);
            },
          ),
          GoRoute(
            path: paywall,
            builder: (context, state) => const PaywallScreen(),
          ),
          GoRoute(
            path: settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/mfa-setup',
            builder: (context, state) => const TwoFactorSetupScreen(),
          ),
          GoRoute(
            path: '/onboarding/professional',
            builder: (context, state) => const ProfessionalOnboardingScreen(),
          ),
          GoRoute(
            path: '/privacy',
            builder: (context, state) => const PrivacyPolicyScreen(),
          ),
          GoRoute(
            path: '/billing/history',
            builder: (context, state) => const BillingHistoryScreen(),
          ),
          GoRoute(
            path: '/plan/upgrade',
            builder: (context, state) => const PlanUpgradeScreen(),
          ),
        ],
        errorBuilder: (context, state) => const ErrorScreen(),
      );
}

// Pantallas temporales hasta que se implementen las reales
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MindCare - Inicio'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenido a MindCare',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Tu compañero de bienestar mental con IA'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => context.go(AppRouter.bienestar),
              child: const Text('Módulo Bienestar'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go(AppRouter.paywall),
              child: const Text('Ver Planes'),
            ),
          ],
        ),
      ),
    );
  }
}

class BienestarScreen extends StatelessWidget {
  const BienestarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienestar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.home),
        ),
      ),
      body: const Center(
        child: Text('Módulo de Bienestar - En desarrollo'),
      ),
    );
  }
}

class TdaTdhScreen extends StatelessWidget {
  const TdaTdhScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TDA/TDAH'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.home),
        ),
      ),
      body: const Center(
        child: Text('Módulo TDA/TDAH - En desarrollo'),
      ),
    );
  }
}

class EstudiantilScreen extends StatelessWidget {
  const EstudiantilScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estudiantil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.home),
        ),
      ),
      body: const Center(
        child: Text('Módulo Estudiantil - En desarrollo'),
      ),
    );
  }
}

class DesarrolloProfesionalScreen extends StatelessWidget {
  const DesarrolloProfesionalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desarrollo Profesional'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.home),
        ),
      ),
      body: const Center(
        child: Text('Módulo de Desarrollo Profesional - En desarrollo'),
      ),
    );
  }
}

class ProfesionalesScreen extends StatelessWidget {
  const ProfesionalesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profesionales'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.home),
        ),
      ),
      body: const Center(
        child: Text('Directorio de Profesionales - En desarrollo'),
      ),
    );
  }
}

class ProfesionalDetailScreen extends StatelessWidget {
  final String professionalId;

  const ProfesionalDetailScreen({
    Key? key,
    required this.professionalId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Profesional'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.profesionales),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ID del Profesional: $professionalId'),
            const SizedBox(height: 20),
            const Text('Perfil del Profesional - En desarrollo'),
          ],
        ),
      ),
    );
  }
}

class BookingScreen extends StatelessWidget {
  final String bookingId;

  const BookingScreen({
    Key? key,
    required this.bookingId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserva'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.profesionales),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ID de la Reserva: $bookingId'),
            const SizedBox(height: 20),
            const Text('Pantalla de Reserva - En desarrollo'),
          ],
        ),
      ),
    );
  }
}

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes y Precios'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.home),
        ),
      ),
      body: const Center(
        child: Text('Paywall - En desarrollo'),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.home),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Configuración - En desarrollo'),
            TextButton(
              onPressed: () => context.go('/privacy'),
              child: const Text('Privacy Policy'),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 8),
            Text('La página que buscas no existe'),
          ],
        ),
      ),
    );
  }
}
