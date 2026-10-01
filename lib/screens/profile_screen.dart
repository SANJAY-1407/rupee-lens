import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../main.dart';
import '../services/expense_service.dart';
import '../services/theme_service.dart';
import '../services/budget_service.dart';
import '../services/pdf_service.dart';
import '../services/backup_service.dart';
import '../services/auth_service.dart';
import '../login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  double monthlyBudget = 0;
  String? profileImagePath;

  bool dailyReminderEnabled = false;

  int reminderHour = 20;
  int reminderMinute = 0;

  late AnimationController _reminderAnimationController;
  late Animation<double> _reminderScaleAnimation;

  @override
  void initState() {
    super.initState();

    loadBudget();
    loadProfileImage();

    _reminderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _reminderScaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1.04,
    ).animate(
      CurvedAnimation(
        parent: _reminderAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _reminderAnimationController.repeat(
      reverse: true,
    );

    loadReminderSettings();
  }

  @override
  void dispose() {
    _reminderAnimationController.dispose();
    super.dispose();
  }


  Future<void> loadBudget() async {
    monthlyBudget = await BudgetService.getBudget();
    if (mounted) setState(() {});
  }

  Future<void> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();

    final savedPath = prefs.getString('profile_image_path');

    if (savedPath != null && savedPath.isNotEmpty) {
      if (mounted) {
        setState(() {
          profileImagePath = savedPath;
        });
      }
    }
  }
  Future<void> loadReminderSettings() async {
    final enabled = await NotificationService.isReminderEnabled();
    final time = await NotificationService.getReminderTime();

    if (!mounted) return;

    setState(() {
      dailyReminderEnabled = enabled;
      reminderHour = time.hour;
      reminderMinute = time.minute;
    });
  }
  String _formatReminderTime() {
    final hour = reminderHour % 12 == 0
        ? 12
        : reminderHour % 12;

    final minute = reminderMinute
        .toString()
        .padLeft(2, '0');

    final period = reminderHour >= 12
        ? "PM"
        : "AM";

    return "$hour:$minute $period";
  }

  Future<void> _selectReminderTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: reminderHour,
        minute: reminderMinute,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: false,
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    await NotificationService.saveReminderTime(
      pickedTime.hour,
      pickedTime.minute,
    );

    await NotificationService.scheduleDailyReminder();

    if (!mounted) return;

    setState(() {
      reminderHour = pickedTime.hour;
      reminderMinute = pickedTime.minute;
    });
  }


  Future<void> pickProfileImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'profile_image_path',
      pickedFile.path,
    );

    if (mounted) {
      setState(() {
        profileImagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: "Logout",
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await AuthService.signOut();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.green,
                  backgroundImage: profileImagePath != null
                      ? FileImage(File(profileImagePath!))
                      : null,
                  child: profileImagePath == null
                      ? const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        )
                      : null,
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: pickProfileImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              user?.email ?? "RupeeLens User",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "Flutter Developer",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () async {
                try {
                  final file = await BackupService.exportBackup();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Backup Saved\n${file.path}"),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.backup),
              label: const Text("Backup Data"),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.receipt_long,
                  color: Colors.green,
                ),
                title: const Text("Total Expenses"),
                trailing: Text(
                  ExpenseService.getExpenseCount().toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.orange,
                ),
                title: const Text("Total Money Spent"),
                trailing: Text(
                  "₹${ExpenseService.getTotalExpense().toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.savings,
                  color: Colors.green,
                ),
                title: const Text("Monthly Budget"),
                subtitle: Text(
                  "₹${monthlyBudget.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final controller = TextEditingController(
                      text: monthlyBudget.toStringAsFixed(0),
                    );
                    final dialogContext = context;
                    final navigator = Navigator.of(context);
                    await showDialog(
                      context: dialogContext,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Set Monthly Budget"),
                          content: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: "Enter Budget",
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final value =
                                    double.tryParse(controller.text) ?? 0;

                                await BudgetService.saveBudget(value);

                                if (!mounted) return;

                                monthlyBudget = value;
                                setState(() {});

                                navigator.pop();
                              },
                              child: const Text("Save"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Divider(),
            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Settings",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ValueListenableBuilder(
                valueListenable: RupeeLensAppState.themeNotifier,
                builder: (context, ThemeMode mode, child) {
                  return SwitchListTile(
                    secondary: const Icon(Icons.dark_mode),
                    title: const Text("Dark Mode"),
                    value: mode == ThemeMode.dark,
                    onChanged: (value) async {
                      RupeeLensAppState.themeNotifier.value =
                          value ? ThemeMode.dark : ThemeMode.light;

                      await ThemeService.saveTheme(value);
                    },
                  );
                },
              ),
            ),
            AnimatedBuilder(
              animation: _reminderAnimationController,
              builder: (context, child) {
                final isDark =
                    Theme.of(context).brightness == Brightness.dark;

                final primaryColor = Theme.of(context).colorScheme.primary;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                        primaryColor.withValues(alpha: 0.18),
                        Colors.white.withValues(alpha: 0.04),
                      ]
                          : [
                        primaryColor.withValues(alpha: 0.10),
                        Colors.white,
                      ],
                    ),
                    border: Border.all(
                      color: dailyReminderEnabled
                          ? primaryColor.withValues(alpha: 0.25)
                          : Colors.grey.withValues(alpha: 0.15),
                    ),
                    boxShadow: dailyReminderEnabled
                        ? [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.12),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ]
                        : [],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Transform.scale(
                            scale: dailyReminderEnabled
                                ? _reminderScaleAnimation.value
                                : 1,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor.withValues(alpha: 0.12),
                              ),
                              child: Icon(
                                dailyReminderEnabled
                                    ? Icons.notifications_active_rounded
                                    : Icons.notifications_none_rounded,
                                color: dailyReminderEnabled
                                    ? primaryColor
                                    : Colors.grey,
                                size: 27,
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Daily Expense Reminder",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  dailyReminderEnabled
                                      ? "We'll remind you if you haven't logged an expense."
                                      : "Get a gentle reminder to track today's spending.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.35,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Switch.adaptive(
                            value: dailyReminderEnabled,
                            activeColor: primaryColor,
                            onChanged: (value) async {
                              setState(() {
                                dailyReminderEnabled = value;
                              });

                              await NotificationService.setReminderEnabled(
                                value,
                              );

                              if (value) {
                                await NotificationService.scheduleDailyReminder();
                              } else {
                                await NotificationService.cancelDailyReminder();
                              }
                            },
                          ),
                        ],
                      ),

                      AnimatedSize(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                        child: dailyReminderEnabled
                            ? Column(
                          children: [
                            const SizedBox(height: 18),

                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.16)
                                    : Colors.white.withValues(alpha: 0.65),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.10),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(13),
                                      color: primaryColor.withValues(alpha: 0.10),
                                    ),
                                    child: Icon(
                                      Icons.access_time_rounded,
                                      color: primaryColor,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Reminder Time",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),

                                        const SizedBox(height: 3),

                                        Text(
                                          _formatReminderTime(),
                                          style: const TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  TextButton(
                                    onPressed: _selectReminderTime,
                                    child: const Text(
                                      "CHANGE",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 16,
                                  color: primaryColor,
                                ),

                                const SizedBox(width: 7),

                                Expanded(
                                  child: Text(
                                    "Only reminds you when today's expense hasn't been logged.",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              },
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.info),
                title: const Text("About RupeeLens"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: "RupeeLens",
                    applicationVersion: "1.0",
                    applicationLegalese: "Developed by Sanjay M",
                    children: const [
                      SizedBox(height: 10),
                      Text("Track every rupee wisely."),
                    ],
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.restore,
                  color: Colors.blue,
                ),
                title: const Text("Restore Backup"),
                subtitle: const Text("Import backup JSON file"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  try {
                    await BackupService.importBackup();

                    if (!mounted) return;

                    setState(() {});

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "✅ Backup Restored Successfully",
                        ),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Restore Failed\n$e",
                        ),
                      ),
                    );
                  }
                },
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red,
                ),
                title: const Text("Export PDF Report"),
                subtitle: const Text("Generate expense report"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  await PdfService.generateExpenseReport();
                },
              ),
            ),

            const SizedBox(height: 10),

            const Card(
              child: ListTile(
                leading: Icon(Icons.star),
                title: Text("Rate App"),
                trailing: Icon(Icons.arrow_forward_ios, size: 18),
              ),
            ),

            const SizedBox(height: 20),

            const ListTile(
              leading: Icon(Icons.info, color: Colors.blue),
              title: Text("App Version"),
              trailing: Text("v1.0"),
            ),

            const ListTile(
              leading: Icon(Icons.code, color: Colors.purple),
              title: Text("Developed By"),
              trailing: Text("Sanjay M"),
            ),

            const SizedBox(height: 20),

            // LOGOUT BUTTON IN PROFILE
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  "LOGOUT",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to log out?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Logout"),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await AuthService.signOut();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "RupeeLens 💙",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Track every rupee wisely.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}