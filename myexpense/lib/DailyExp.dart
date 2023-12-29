

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:myfin/ExpEdit.dart';


class DailyExp extends StatelessWidget {
  final String selectedDate;
  final List<DocumentSnapshot> documents;

  DailyExp({required this.selectedDate, required this.documents});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Expenses'),
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
          List<DocumentSnapshot> updatedDocuments = snapshot.data!.docs;

          // Filter documents based on the selected date
          List<DocumentSnapshot> filteredDocuments = updatedDocuments
              .where((document) {
                Timestamp timestamp = document['date'];
                DateTime dateTime = timestamp.toDate();
                String documentDate = DateFormat('yyyy-MM-dd').format(dateTime);
                return documentDate == selectedDate;
              })
              .toList();

          return ListView.builder(
            itemCount: filteredDocuments.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data = filteredDocuments[index].data() as Map<String, dynamic>;
              Timestamp timestamp = data['date'] ?? Timestamp(0, 0);

              // Convert timestamp to DateTime
              DateTime dateTime = timestamp.toDate();

              // Format DateTime as a string (only date part)
              String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

              double totalExpenses = (data['amount'] ?? 0).toDouble();

              return ListTile(
                title: Text('$formattedDate'),
                subtitle: Text('Total Expenses: \$${totalExpenses.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                     onPressed: () {
    // Handle edit action for the selected document
    _editExpense(context, updatedDocuments[index]);
  },

                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // Show confirmation dialog before deleting
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirm Deletion'),
                              content: Text('Are you sure you want to delete this document?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    // Cancel deletion
                                    Navigator.pop(context);
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Delete the document
                                    _deleteDocument(filteredDocuments[index].id);
                                    // Close the confirmation dialog (it will be rebuilt by StreamBuilder)
                                    Navigator.pop(context);
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _deleteDocument(String documentId) {
    // Perform the document deletion from Firestore
    FirebaseFirestore.instance.collection('expdetails').doc(documentId).delete();

    // Optionally, you can show a message or perform other actions after deletion
    print('Document deleted in real-time: $documentId');
  }
}
void _editExpense(BuildContext context, DocumentSnapshot document) {
  // Extract the expense details from the document
  Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

  if (data != null && data.containsKey('amount')) {
    String title = data['title'] ?? '';
    String description = data['description'] ?? '';
    dynamic amount = data['amount'];

    // Perform a null check and convert to double
    double initialAmount = (amount is double) ? amount : double.tryParse(amount.toString()) ?? 0.0;

    // Navigate to HomePage with the details for editing
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpEdit(
          initialDate: DateTime.parse(data['date'].toDate().toString()),
          initialCategory: data['category'] ?? '',
          initialTitle: title,
          initialDescription: description,
          initialAmount: initialAmount,
          isEditing: true,
        ),
      ),
    );
  } else {
    // Handle the case where 'amount' is not present or null
    print('Error: Unable to retrieve valid expense data for editing.');
  }
}
