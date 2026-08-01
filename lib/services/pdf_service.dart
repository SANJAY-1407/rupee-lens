import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'expense_service.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateExpenseReport() async {
    final pdf = pw.Document();

    final categoryTotals = ExpenseService.getCategoryTotals();

    final total = ExpenseService.getTotalExpense();
    final cashTotal = ExpenseService.getCashTotal();
    final upiTotal = ExpenseService.getUpiTotal();

    final now = DateTime.now();
    final date = DateFormat('dd-MM-yyyy').format(now);
    final time = DateFormat('hh:mm a').format(now);
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              pw.Text(
                "RupeeLens Expense Report",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text("Generated Date : $date"),
              pw.Text("Generated Date : $date"),
              pw.Text("Time : $time"),

              pw.SizedBox(height: 20),

              pw.Text(
                "Payment Method",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              pw.SizedBox(height: 10),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Cash"),
                  pw.Text("₹${cashTotal.toStringAsFixed(2)}"),
                ],
              ),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("UPI"),
                  pw.Text("₹${upiTotal.toStringAsFixed(2)}"),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.SizedBox(height: 20),

              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 1),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "TOTAL EXPENSE",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      "₹${total.toStringAsFixed(2)}",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              pw.Divider(),
              pw.SizedBox(height: 20),

              pw.Text(
                "Category Report",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              ...categoryTotals.entries.map(
                    (entry) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Row(
                    mainAxisAlignment:
                    pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        entry.key,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        "₹${entry.value.toStringAsFixed(2)}",
                      ),
                      pw.Divider(),

                      pw.SizedBox(height: 15),

                      pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          "Category Report",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                          pw.SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              pw.Divider(),
              pw.SizedBox(height: 20),

              pw.Text(
                "Category Report",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              pw.SizedBox(height: 10),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "TOTAL",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  pw.Text(
                    "₹${total.toStringAsFixed(2)}",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),

              pw.Divider(),

              pw.SizedBox(height: 20),

              pw.Text(
                "Generated by RupeeLens",
                style: const pw.TextStyle(
                  color: PdfColors.grey,
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}