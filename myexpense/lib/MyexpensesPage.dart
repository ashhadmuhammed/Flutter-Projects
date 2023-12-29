import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfin/DailyExp.dart';

class MyexpensesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses Page'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('expdetails').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // Extract data from snapshot
          List<DocumentSnapshot> documents = snapshot.data!.docs;

          // Map to store total expenses for each date
          Map<String, double> totalExpensesByDate = {};

          // Calculate total expenses for each date
          for (var document in documents) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            Timestamp timestamp = data['date'] ?? Timestamp(0, 0);

            // Convert timestamp to DateTime
            DateTime dateTime = timestamp.toDate();

            // Format DateTime as a string (only date part)
            String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

            // Update total expenses for the date
            totalExpensesByDate[formattedDate] =
                (totalExpensesByDate[formattedDate] ?? 0) +
                    (data['amount'] ?? 0).toDouble();
          }

          return ListView.builder(
            itemCount: totalExpensesByDate.length,
            itemBuilder: (context, index) {
              String date = totalExpensesByDate.keys.elementAt(index);
              double totalExpenses = totalExpensesByDate[date]!;

              return ListTile(
                title: Text('$date'),
                subtitle: Text(
                    'Total Expenses: \$${totalExpenses.toStringAsFixed(2)}'),
              onTap: () async {
  // Extract the tapped date
  String tappedDate = totalExpensesByDate.keys.elementAt(index);
  print("selected");
   print(tappedDate);
    print("selected");
  // Filter the documents based on the tapped date
  List<DocumentSnapshot> documentsForTappedDate = documents
      .where((document) {
        Timestamp timestamp = document['date'];
        DateTime dateTime = timestamp.toDate();
        String documentDate = DateFormat('yyyy-MM-dd').format(dateTime);
        print(documentDate);
        return documentDate == tappedDate;
      })
      .toList();
// Print the filtered documents before passing to DailyExp
  // Print the entire list of documents for debugging purposes
  documentsForTappedDate.forEach((document) {
    print('Document: ${document.data()}');
  });

  // Navigate to DailyExp page with documents for the tapped date
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DailyExp(selectedDate: tappedDate, documents: documentsForTappedDate),
    ),
  );

  // Optionally, you can perform actions after returning from DailyExp
  print('Returned from DailyExp');
},

              );
            },
          );
        },
      ),
    );
  }
}
