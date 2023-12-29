import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpEdit extends StatefulWidget {
  @override
  _ExpEditState createState() => _ExpEditState();

  final DateTime initialDate;
  final String initialCategory;
  final String initialTitle;
  final String initialDescription;
  final double  initialAmount;
  final bool isEditing;

  ExpEdit({
    required this.initialDate,
    required this.initialCategory,
    required this.initialTitle,
    required this.initialDescription,
    required this.initialAmount,
    this.isEditing = false,
  });
 
}

class _ExpEditState extends State<ExpEdit> {
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Food'; // Default category
  final _expenseTitleController = TextEditingController();
  final _expenseDescriptionController = TextEditingController();
  final _expenseAmountController = TextEditingController();

  void _submitExpense() {
    // Handle the logic for submitting the expense
    // You can access the entered values using _expenseTitleController.text,
    // _expenseDescriptionController.text, _selectedCategory, and _expenseAmountController.text
    print('Expense submitted:');
    print('Title: ${_expenseTitleController.text}');
    print('Description: ${_expenseDescriptionController.text}');
    print('Category: $_selectedCategory');
    print('Amount: ${_expenseAmountController.text}');
    // Add your logic here to process the expense data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Text(
              //   'Welcome to the Home Page!',
              //   style: TextStyle(fontSize: 20),
              // ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text(_selectedDate.toString().split(' ')[0]),
              ),
              // SizedBox(height: 20),
              // Align(
              //   alignment: Alignment.topCenter,
              //   child: Text(
              //     'Selected Date:${_selectedDate.toLocal().toString().split(' ')[0]}',
              //     style: TextStyle(fontSize: 16),
              //   ),
              // ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: _selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                items: <String>['Food', 'Travel', 'Shopping', 'Accommodation']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),

              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextField(
                  controller: _expenseTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Expense Title',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextField(
                  controller: _expenseDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Desciption',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextField(
                  controller: _expenseAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    CollectionReference coll =
                        FirebaseFirestore.instance.collection('expdetails');
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await coll.add({
                        'userId': user.uid, // Add the user ID to the Firestore document
                        'title': _expenseTitleController.text,
                        'description': _expenseDescriptionController.text,
                        'amount': _expenseAmountController.text,
                      });

                      print(
                          'Expense added successfully for user ID: ${user.uid}');
                    } else {
                      print('No user is currently logged in');
                    }
                  } catch (e) {
                    print('Error adding expense: $e');
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
}
