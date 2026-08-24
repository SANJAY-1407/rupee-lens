import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../main.dart';
import '../services/expense_service.dart';
import '../services/theme_service.dart';
import '../services/budget_service.dart';
import '../services/pdf_service.dart';
import '../services/backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double monthlyBudget = 0;
  String? profileImagePath;

  @override
  void initState() {
    super.initState();

    loadBudget();
    loadProfileImage();
  }

  Future<void> loadBudget() async {
    monthlyBudget = await BudgetService.getBudget();
    setState(() {});
  }
  Future<void> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();

    final savedPath = prefs.getString('profile_image_path');

    if (savedPath != null && savedPath.isNotEmpty) {
      setState(() {
        profileImagePath = savedPath;
      });
    }
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

    Future<void> loadProfileImage() async {
      final prefs = await SharedPreferences.getInstance();

      final savedPath = prefs.getString('profile_image_path');

      if (savedPath != null && savedPath.isNotEmpty) {
        setState(() {
          profileImagePath = savedPath;
        });
      }
    }


    setState(() {
      profileImagePath = pickedFile.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
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
            ElevatedButton.icon(
              onPressed: () async {
                print("BUTTON CLICKED");

                try {
                  final file = await BackupService.exportBackup();

                  print("SUCCESS");
                  print(file.path);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Backup Saved\n${file.path}"),
                    ),
                  );
                } catch (e) {
                  print(e);

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

            const Text(
              "SANJAY..",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "Flutter Developer",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

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

            const Divider(),const SizedBox(height: 20),

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

            Card(
              child: ListTile(
                leading: Icon(Icons.notifications),
                title: Text("Notifications"),
                trailing: Icon(Icons.arrow_forward_ios, size: 18),
              ),
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


            Card(
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