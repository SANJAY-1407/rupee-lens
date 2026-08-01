import 'package:flutter/material.dart';
import '../main.dart';
import '../services/expense_service.dart';
import '../services/theme_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

            const CircleAvatar(
              radius: 55,
              backgroundColor: Colors.green,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Sanjay M",
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
              "RupeeLens 💚💓",
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