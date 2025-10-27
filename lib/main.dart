import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const OralAuraApp());
}

/// Version 0.1.0 (Prototype)
class InMemoryDB {
  static final InMemoryDB _i = InMemoryDB._();
  InMemoryDB._();
  factory InMemoryDB() => _i;

  final List<ScanRecord> scans = [];
  int scansThisMonth() {
    final now = DateTime.now();
    return scans.where((s) => s.created.month == now.month && s.created.year == now.year).length;
  }

  void addScan(ScanRecord s) => scans.insert(0, s);
}

class ScanRecord {
  final String id;
  final DateTime created;
  final String severity; // monitor | routine_dentist | urgent
  final List<String> flags;
  ScanRecord({
    required this.id,
    required this.created,
    required this.severity,
    required this.flags,
  });
}

class OralAuraApp extends StatelessWidget {
  const OralAuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF2A6EE8));
    return MaterialApp(
      title: 'OralAura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(fontWeight: FontWeight.w700),
        ),
        cardTheme: CardTheme(
          elevation: 1,
          surfaceTintColor: scheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      home: const SplashGate(),
      routes: {
        OnboardingScreen.route: (_) => const OnboardingScreen(),
        LoginScreen.route: (_) => const LoginScreen(),
        HomeScreen.route: (_) => const HomeScreen(),
        ScanFlowScreen.route: (_) => const ScanFlowScreen(),
        ResultsScreen.route: (_) => const ResultsScreen(),
        RemindersScreen.route: (_) => const RemindersScreen(),
        SettingsScreen.route: (_) => const SettingsScreen(),
        DentistFinderScreen.route: (_) => const DentistFinderScreen(),
      },
    );
  }
}

/* ----------------------------- PAGE 1: Splash → Onboarding ----------------------------- */

class SplashGate extends StatefulWidget {
  const SplashGate({super.key});
  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {  // change time to preference
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(OnboardingScreen.route);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: BrandedBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'images/ORALAURA.png',
                  width: 140,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text('OralAura', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 8),
                Text(
                  'Your AI-Powered Guide to Proactive Oral Health',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: cs.onSurface.withOpacity(0.72)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  static const route = '/onboarding';
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pages = [
      _OnboardSlide(
        icon: Icons.health_and_safety_rounded,
        title: 'Welcome to OralAura',
        body: 'Democratizing access to initial oral health screening—right from your phone.',
      ),
      _OnboardSlide(
        icon: Icons.camera_alt_rounded,
        title: 'How it works',
        body:
            'Take clear photos of your mouth. We analyze them for potential concerns like discolorations, lesions, or ulcers.',
      ),
      _OnboardSlide(
        icon: Icons.gpp_maybe_rounded,
        title: 'Important',
        body:
            'OralAura is NOT a diagnosis and NOT a replacement for a dentist. It’s a guide to help you decide next steps.',
        warning: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const _LogoTitle(title: 'Get Started'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, LoginScreen.route),
            child: const Text('Skip'),
          ),
        ],
      ),
      body: BrandedBackground(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: controller,
                onPageChanged: (i) => setState(() => index = i),
                children: pages,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.all(4),
                  height: 8,
                  width: i == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: i == index ? cs.primary : cs.outlineVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: index == 0
                          ? null
                          : () => controller.previousPage(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                              ),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (index == pages.length - 1) {
                          Navigator.pushReplacementNamed(context, LoginScreen.route);
                        } else {
                          controller.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                      child: Text(index == pages.length - 1 ? 'Continue' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardSlide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final bool warning;
  const _OnboardSlide({required this.icon, required this.title, required this.body, this.warning = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LogoMark(size: 64, color: cs.primary),
              const SizedBox(height: 12),
              Icon(icon, size: 56, color: warning ? cs.error : cs.primary),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(body,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: warning ? cs.error : cs.onSurfaceVariant,
                    fontSize: 16,
                    height: 1.4,
                  )),
              if (warning) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Educational guidance only — not a medical device and not a diagnosis.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onErrorContainer),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  static const route = '/login';
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool obscure = true;

  void _goHome() {
    Navigator.pushReplacementNamed(context, HomeScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const _LogoTitle(title: 'Sign in')),
      body: BrandedBackground(
        padding: const EdgeInsets.all(20),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Center(child: _LogoMark(size: 72, color: cs.primary)),
            const SizedBox(height: 8),
            Center(
              child: Text('OralAura', style: Theme.of(context).textTheme.headlineMedium),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pass,
              obscureText: obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => obscure = !obscure),
                  icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _goHome, child: const Text('Continue')),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                // Placeholder for Google Firebase Auth integration
                // NEED TO DO
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Google Sign-In would happen here.')),
                );
                _goHome();
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.account_circle_outlined), SizedBox(width: 8), Text('Continue with Google')],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* --------------------------------- PAGE 2: Home (Dashboard) --------------------------------- */

class HomeScreen extends StatelessWidget {
  static const route = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = InMemoryDB();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const _LogoTitle(title: 'OralAura'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, SettingsScreen.route),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, ScanFlowScreen.route),
        label: const Text('New Scan'),
        icon: const Icon(Icons.add_a_photo_rounded),
      ),
      body: BrandedBackground(
        padding: const EdgeInsets.all(16),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _HeaderCard(
              title: 'Welcome back',
              subtitle: 'Ready for a quick check-in?',
              avatar: const CircleAvatar(child: Icon(Icons.person)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'Scans this month',
                    value: db.scansThisMonth().toString(),
                    icon: Icons.calendar_month_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    label: 'Total scans',
                    value: db.scans.length.toString(),
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Recent Scans', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (db.scans.isEmpty)
              _EmptyState(
                icon: Icons.image_search_outlined,
                title: 'No scans yet',
                body: 'Tap “New Scan” to begin.',
              )
            else
              ...db.scans.map(
                (s) => _ScanListTile(record: s, color: _severityColor(context, s.severity)),
              ),
            const SizedBox(height: 96), // breathing room for FAB
          ],
        ),
      ),
    );
  }
}

/* ---------------------------- PAGE 3: Scanning Process (temporary, no api) ---------------------------- */

class ScanFlowScreen extends StatefulWidget {
  static const route = '/scan';
  const ScanFlowScreen({super.key});
  @override
  State<ScanFlowScreen> createState() => _ScanFlowScreenState();
}

class _ScanFlowScreenState extends State<ScanFlowScreen> {
  int step = 0;
  bool hasImage = false;
  double progress = 0.0;
  Timer? _timer;

  void _mockCapture() {
    setState(() => hasImage = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image captured (mock).')));
  }

  void _mockUploadAnalyze() {
    setState(() {
      progress = 0;
      step = 2;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 120), (t) {
      setState(() => progress = (progress + 0.07).clamp(0, 1));
      if (progress >= 1) {
        t.cancel();
        // Generate a mock result + store it.
        final severities = ['monitor', 'routine_dentist', 'urgent'];
        final severity = severities[Random().nextInt(severities.length)];
        final flags = switch (severity) {
          'urgent' => ['active_bleeding_or_ulcer_suspected'],
          'routine_dentist' => ['tissue_irritation_suspected'],
          _ => ['monitoring_suggested'],
        };
        final rec = ScanRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          created: DateTime.now(),
          severity: severity,
          flags: flags,
        );
        InMemoryDB().addScan(rec);
        Navigator.pushReplacementNamed(context, ResultsScreen.route, arguments: rec);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildGuide(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Camera Guide', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: cs.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: Icon(Icons.camera_alt_rounded, size: 64)),
                      ),
                      // Simple overlay guides
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: cs.primary, width: 2),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Tip: good lighting, open mouth “ahh”, steady hands.',
                            style: TextStyle(color: cs.onPrimaryContainer),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.light_mode_outlined),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Stand near a light source, avoid harsh shadows.'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.center_focus_weak_outlined),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Center the area of concern in the frame.'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => setState(() => step = 1),
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('I’m ready'),
        ),
      ],
    );
  }

  Widget _buildCapture(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Image Capture', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(hasImage ? Icons.check_circle_rounded : Icons.photo_camera_back_outlined, size: 72),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _mockCapture,
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Open Camera (mock)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: hasImage ? () => setState(() => step = 2) : null,
                        icon: const Icon(Icons.upload_file_rounded),
                        label: const Text('Upload & Analyze'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpload(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Upload & Analysis', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                LinearProgressIndicator(value: progress == 0 ? null : progress),
                const SizedBox(height: 12),
                Text(progress >= 1 ? 'Complete' : 'Analyzing image…'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: progress > 0 ? null : _mockUploadAnalyze,
                        child: const Text('Start (mock)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _buildGuide(context),
      _buildCapture(context),
      _buildUpload(context),
    ];

    return Scaffold(
      appBar: AppBar(title: const _LogoTitle(title: 'New Scan')),
      body: BrandedBackground(
        padding: const EdgeInsets.all(16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: steps[step],
        ),
      ),
    );
  }
}

/* --------------------------- PAGE 4: Results & Education (mock) --------------------------- */

class ResultsScreen extends StatelessWidget {
  static const route = '/results';
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScanRecord rec = ModalRoute.of(context)?.settings.arguments is ScanRecord
        ? ModalRoute.of(context)!.settings.arguments as ScanRecord
        : (InMemoryDB().scans.isNotEmpty ? InMemoryDB().scans.first : _fallbackScan());

    final color = _severityColor(context, rec.severity);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const _LogoTitle(title: 'Results')),
      body: BrandedBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(width: 10, height: 72, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Summary', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 6),
                          Text(
                            _summaryText(rec),
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: rec.flags.map((f) => Chip(label: Text(f.replaceAll('_', ' ')))).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Annotated Image', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: cs.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: Icon(Icons.face_3_rounded, size: 80)),
                      ),
                      // Simple translucent highlight boxes (mock)
                      Positioned(
                        left: 24,
                        top: 24,
                        width: 90,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.amber, width: 2),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 32,
                        bottom: 28,
                        width: 70,
                        height: 48,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(context, DentistFinderScreen.route),
                    icon: const Icon(Icons.medical_services_outlined),
                    label: const Text('Find a Dentist'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, RemindersScreen.route),
                    icon: const Icon(Icons.alarm_add_outlined),
                    label: const Text('Set a Reminder'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _InfoCard(
              icon: Icons.info_outline_rounded,
              title: 'Educational tips',
              body:
                  'Avoid spicy/acidic foods around irritated tissue. Keep the area clean. If symptoms persist or worsen, book a dental exam.',
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }

  static ScanRecord _fallbackScan() => ScanRecord(
        id: 'sample',
        created: DateTime.now(),
        severity: 'routine_dentist',
        flags: const ['tissue_irritation_suspected'],
      );

  String _summaryText(ScanRecord rec) {
    return switch (rec.severity) {
      'urgent' =>
        'We suggest urgent evaluation. If heavy bleeding, severe pain, or fever occurs, go to urgent care/ER. Otherwise, contact a dentist within 24–48 hours.',
      'routine_dentist' =>
        'Book a routine dental exam within a week and monitor the area. Avoid irritants (spicy/acidic foods).',
      _ => 'Monitor the area. If it persists beyond 7 days or worsens, schedule a dental visit.',
    };
  }
}

/* --------------------------------- PAGE 5: Reminders (integrate with google calendar api) -------------------------------- */

class RemindersScreen extends StatefulWidget {
  static const route = '/reminders';
  const RemindersScreen({super.key});
  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final reminders = <String>[];

  void _addReminder() async {
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('New Reminder'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(hintText: 'e.g., Recheck sore spot in 3 days'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Save')),
          ],
        );
      },
    );
    if (text != null && text.isNotEmpty) {
      setState(() => reminders.add(text));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder saved (mock).')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const _LogoTitle(title: 'Reminders')),
      floatingActionButton: FloatingActionButton(onPressed: _addReminder, child: const Icon(Icons.add)),
      body: BrandedBackground(
        child: reminders.isEmpty
            ? const Center(
                child: _EmptyState(
                  icon: Icons.alarm_on_outlined,
                  title: 'No reminders yet',
                  body: 'Add one to follow up on an area of concern.',
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: reminders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.alarm_outlined),
                    title: Text(reminders[i]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => setState(() => reminders.removeAt(i)),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

/* ------------------------------- PAGE 6: Settings & About Us ------------------------------- */

class SettingsScreen extends StatelessWidget {
  static const route = '/settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const _LogoTitle(title: 'Settings & About')),
      body: BrandedBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: cs.primaryContainer, child: const Icon(Icons.person)),
                title: const Text('Your Profile'),
                subtitle: const Text('Tap to edit (mock)'),
                onTap: () => ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Profile editing would go here.'))),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                title: const Text('Dark Mode'),
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (_) => ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Theme toggling not wired in this demo.'))),
              ),
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy reminder',
              body:
                  'Images you capture may include sensitive health information. Only share with providers you trust. This demo stores nothing remotely.',
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About OralAura'),
              subtitle: const Text('Version 0.1.0 (Prototype)'),
            ),
          ],
        ),
      ),
    );
  }
}

/* ------------------------------- Dentist Finder (this will connect with Maps API) ------------------------------ */

class DentistFinderScreen extends StatelessWidget {
  static const route = '/dentist';
  const DentistFinderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      6,
      (i) => ('Smile Clinic #$i', '1.${i} mi • Open until 6pm'),
    );
    return Scaffold(
      appBar: AppBar(title: const _LogoTitle(title: 'Find a Dentist')),
      body: BrandedBackground(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final (title, subtitle) = items[i];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.local_hospital_outlined),
                title: Text(title),
                subtitle: Text(subtitle),
                trailing: FilledButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Would open Maps for "$title" (mock).')),
                  ),
                  child: const Text('Directions'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/* -------------------------------------- Widgets -------------------------------------- */

class BrandedBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const BrandedBackground({required this.child, this.padding, super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Widget content = padding != null ? Padding(padding: padding!, child: child) : child;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.surface,
            cs.surfaceVariant.withOpacity(0.4),
            cs.primaryContainer.withOpacity(0.35),
          ],
          stops: const [0, 0.45, 1],
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -30,
            child: _BackgroundOrb(
              diameter: 260,
              colors: [
                cs.primary.withOpacity(0.35),
                cs.primary.withOpacity(0.05),
              ],
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: _BackgroundOrb(
              diameter: 280,
              colors: [
                cs.secondary.withOpacity(0.28),
                cs.secondary.withOpacity(0.05),
              ],
            ),
          ),
          Positioned(
            top: 160,
            left: 48,
            child: Transform.rotate(
              angle: -pi / 12,
              child: Container(
                width: 220,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  gradient: LinearGradient(
                    colors: [
                      cs.onPrimary.withOpacity(0.12),
                      cs.onPrimary.withOpacity(0.02),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.surface.withOpacity(0.02),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  final double diameter;
  final List<Color> colors;
  const _BackgroundOrb({required this.diameter, required this.colors});

  @override
  Widget build(BuildContext context) {
    final base = colors.first;
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors, radius: 0.9),
        boxShadow: [
          BoxShadow(
            color: base.withOpacity(0.25),
            blurRadius: diameter * 0.4,
            spreadRadius: diameter * 0.08,
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget avatar;
  const _HeaderCard({required this.title, required this.subtitle, required this.avatar});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                'images/ORALAURA.png',
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
              ]),
            ),
            const SizedBox(width: 12),
            avatar,
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: cs.secondaryContainer,
              child: Icon(icon, color: cs.onSecondaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: TextStyle(color: cs.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.titleLarge),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanListTile extends StatelessWidget {
  final ScanRecord record;
  final Color color;
  const _ScanListTile({required this.record, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.image_rounded, color: color),
        ),
        title: Text(
          '${record.severity.replaceAll('_', ' ')}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${record.created.toLocal()}'.split('.').first),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.pushNamed(context, ResultsScreen.route, arguments: record),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _EmptyState({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icon, size: 64, color: cs.outline),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(body, textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _InfoCard({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: cs.tertiaryContainer,
              child: Icon(icon, color: cs.onTertiaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(body, style: TextStyle(color: cs.onSurfaceVariant)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoTitle extends StatelessWidget {
  final String title;
  final double logoHeight;
  const _LogoTitle({required this.title, this.logoHeight = 28});

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context).style;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'images/ORALAURA.png',
          height: logoHeight,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Text(title, style: defaultStyle),
      ],
    );
  }
}

class _LogoMark extends StatelessWidget {
  final double size;
  final Color color;
  const _LogoMark({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = color.withOpacity(0.12);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      padding: EdgeInsets.all(size * 0.16),
      child: Image.asset(
        'images/ORALAURA.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

/* ----------------------------------- Helpers ----------------------------------- */

Color _severityColor(BuildContext context, String severity) {
  final cs = Theme.of(context).colorScheme;
  return switch (severity) {
    'urgent' => Colors.red,
    'routine_dentist' => cs.primary,
    _ => Colors.green,
  };
}
