import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm/firebase_options.dart';
import 'package:farm/report.dart';
import 'package:farm/services/authservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      //  home: AuthService().currentUser == null? const MyHomePage() : const Home(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool register = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                register ? const LoginForm() : const RegisterForm(),
                const SizedBox(
                  height: 10,
                ),
                register
                    ? const Text("Don't have an account?")
                    : const Text("Already have an account?"),
                TextButton(
                  onPressed: () {
                    if (register == true) {
                      setState(() {
                        register = false;
                      });
                    } else {
                      setState(() {
                        register = true;
                      });
                    }
                  },
                  child:
                      register ? const Text('Register') : const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = "";
  String _password = "";


  Future<void> checkUserAndNavigate() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      final userType = userData['userType'];
      if (userType == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminHome()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Home()),
        );
      }
    }
  }
}



  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              'Login',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email address.';
              }
              return null;
            },
            onSaved: (value) {
              setState(() {
                _email = value!;
              });
            },
          ),
          const SizedBox(height: 10.0),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true, // Hides the password characters
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password.';
              }
              return null;
            },
            onSaved: (value) {
              setState(() {
                _password = value!;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  // Handle forgot password functionality
                  print('Forgot password clicked');
                },
                child: const Text('Forgot Password?'),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton.filled(
                  child: const Text('Login'),
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        });
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      if (await AuthService().login(_email, _password)) {
                        Navigator.of(context).pop();
                        checkUserAndNavigate();
                       // Navigator.of(context).pushReplacement(MaterialPageRoute(
                       //     builder: (context) => const Home()));
                      } else {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Login Failed, Wrong credentials!'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  }),
            ],
          )
        ],
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  String _email = "";
  String _password = "";
  String _accountType = "Farmer";
  String? _farmName;

  Future<void> checkUserAndNavigate() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      final userType = userData['userType'];
      if (userType == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminHome()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Home()),
        );
      }
    }
  }
}




  @override
  Widget build(BuildContext context) {
    final bool _showFarmInput = _accountType == "Farmer";
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              'Register',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ),
          DropdownButtonFormField<String>(
            value: _accountType, // Set initial value
            hint: Text('Select Account Type'),
            items: [
              DropdownMenuItem(
                value: 'Admin',
                child: Text('Admin'),
              ),
              DropdownMenuItem(
                value: 'Farmer',
                child: Text('Farmer'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _accountType = value!;
              });
            },
          ),
          SizedBox(height: 10.0),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name.';
              }
              return null;
            },
            onSaved: (value) {
              setState(() {
                _name = value!;
              });
            },
          ),
          const SizedBox(height: 10.0),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email address.';
              }
              return null;
            },
            onSaved: (value) {
              setState(() {
                _email = value!;
              });
            },
          ),
          const SizedBox(height: 10.0),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true, // Hides the password characters
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password.';
              }
              return null;
            },
            onSaved: (value) {
              setState(() {
                _password = value!;
              });
            },
          ),
          SizedBox(height: 10.0),
          Visibility(
            visible:
                _showFarmInput, // Control visibility based on _showFarmInput
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Farm Name (for Farmers only)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (_accountType == 'Farmer' &&
                    (value == null || value.isEmpty)) {
                  return 'Please enter your farm name.';
                }
                return null;
              },
              onSaved: (value) {
                // Save farm name if account type is Farmer
                if (_accountType == 'Farmer') {
                  setState(() {
                    _farmName = value;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton.filled(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        });
                    if (await AuthService().register(
                        _name, _email, _password, _accountType, _farmName)) {}
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const Home()));
                    print('Name: $_name, Email: $_email, Password: $_password');
                    Navigator.of(context).pop();
                    checkUserAndNavigate();
                   // Navigator.of(context).pushReplacement(
                    //    MaterialPageRoute(builder: (context) => const Home()));
                  } else {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error registering user!'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(AuthService().currentUser?.uid)
              .snapshots(), // Use snapshots() instead of get() to listen for changes

          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}'); // Handle errors
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Show loading indicator
            }

            // Access the document data
            final farmName = snapshot.data!.data()?['farmName'] as String?;

            return Text(
              farmName ?? '', // Use null check and provide a default value
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              AuthService().signOut();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MyHomePage()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Ensures scrollable content if overflow
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                 decoration: BoxDecoration(
                  color: const Color.fromARGB(41, 151, 92, 16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  onPressed: () {
                     Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ReportPage()));
                  },
                  child:const  Text('Generate Report'),
                ),
              ),
              SizedBox(height: 10,),
              Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(41, 151, 92, 16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          final _cattleIdController = TextEditingController();

                          await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Insert Cattle'),
                                content: TextFormField(
                                  controller: _cattleIdController,
                                  decoration: const InputDecoration(
                                    labelText: 'Cattle ID (e.g., C001)',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a Cattle ID.';
                                    }
                                    return null;
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (_cattleIdController.text.isNotEmpty) {
                                        final uid = FirebaseAuth
                                            .instance.currentUser!.uid;
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(uid)
                                            .collection('cattle')
                                            .doc(_cattleIdController.text)
                                            .set({
                                          'cattleId':
                                              _cattleIdController.text.trim(),
                                        });
                                      }

                                      Navigator.pop(context);
                                    },
                                    child: const Text('Add'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: SvgPicture.asset(
                          'assets/heifer.svg',
                          width: 30,
                          height: 30,
                          color: Theme.of(context).primaryColor,
                        ),
                        label: const Text('Cattle'),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final _feedingDateController =
                              TextEditingController();
                          final _feedTypeController = TextEditingController();
                          final _feedQuantityController =
                              TextEditingController();
                          final _notesController = TextEditingController();

                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Record Feeding'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize:
                                          MainAxisSize.min, // Avoid overflow
                                      children: [
                                        TextFormField(
                                          controller: _feedingDateController,
                                          decoration: const InputDecoration(
                                            labelText:
                                                'Feeding Date (YYYY-MM-DD)',
                                          ),
                                          keyboardType: TextInputType
                                              .datetime, // Keyboard for date input
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter a feeding date.';
                                            }
                                            return null;
                                          },
                                        ),
                                        TextFormField(
                                          controller: _feedTypeController,
                                          decoration: const InputDecoration(
                                            labelText: 'Feed Type',
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter the feed type.';
                                            }
                                            return null;
                                          },
                                        ),
                                        TextFormField(
                                          controller: _feedQuantityController,
                                          decoration: const InputDecoration(
                                            labelText:
                                                'Feed Quantity (e.g., kgs, lbs)',
                                          ),
                                          keyboardType: TextInputType
                                              .number, // Keyboard for numeric input
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter the feed quantity.';
                                            }
                                            return null;
                                          },
                                        ),
                                        // Additional fields based on your requirements (replace with actual widgets)
                                        // Dropdown to select cattle (replace with data fetching logic)
                                        DropdownButtonFormField<String>(
                                          hint: const Text('Select Cattle'),
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'Cow 1',
                                              child: Text('Cow 1'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'Cow 2',
                                              child: Text('Cow 2'),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            // Update selected cattle
                                          },
                                        ),
                                        TextFormField(
                                          controller:
                                              _notesController, // Add a notes controller
                                          decoration: const InputDecoration(
                                            labelText: 'Notes (Optional)',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        if (_feedingDateController
                                                .text.isNotEmpty &&
                                            _feedTypeController
                                                .text.isNotEmpty &&
                                            _feedQuantityController
                                                .text.isNotEmpty) {
                                          final uid = FirebaseAuth
                                              .instance.currentUser!.uid;
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(uid)
                                              .collection('feeding')
                                              .doc()
                                              .set({
                                            'date': _feedingDateController.text,
                                            'type': _feedTypeController
                                                .text.isNotEmpty,
                                            'quantity':
                                                _feedQuantityController.text,
                                            'notes': _notesController
                                                    .text.isNotEmpty
                                                ? _notesController.text.trim()
                                                : '',
                                          });
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text('Save'),
                                    ),
                                  ],
                                );
                              });
                        },
                        icon: SvgPicture.asset(
                          'assets/hay.svg',
                          width: 30,
                          height: 30,
                          color: Theme.of(context).primaryColor,
                        ),
                        label: const Text('Feeding'),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final _milkingDateController =
                              TextEditingController();
                          final _milkQuantityController =
                              TextEditingController();
                          final _milkingTime = [
                            'Morning',
                            'Afternoon',
                            'Evening'
                          ];
                          String selectedTime =
                              _milkingTime[0]; // Default selection

                          await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Record Milking'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize:
                                        MainAxisSize.min, // Avoid overflow
                                    children: [
                                      TextFormField(
                                        controller: _milkingDateController,
                                        decoration: const InputDecoration(
                                          labelText:
                                              'Milking Date (YYYY-MM-DD)',
                                        ),
                                        keyboardType: TextInputType
                                            .datetime, // Keyboard for date input
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a milking date.';
                                          }
                                          return null;
                                        },
                                      ),
                                      TextFormField(
                                        controller: _milkQuantityController,
                                        decoration: const InputDecoration(
                                          labelText: 'Milk Quantity (Liters)',
                                        ),
                                        keyboardType: TextInputType
                                            .number, // Keyboard for numeric input
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter the milk quantity.';
                                          }
                                          return null;
                                        },
                                      ),
                                      DropdownButtonFormField<String>(
                                        value: selectedTime,
                                        hint: const Text('Select Milking Time'),
                                        items: _milkingTime
                                            .map((time) =>
                                                DropdownMenuItem<String>(
                                                  value: time,
                                                  child: Text(time),
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedTime = value!;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (_milkingDateController
                                              .text.isNotEmpty &&
                                          _milkQuantityController
                                              .text.isNotEmpty) {
                                        final uid = FirebaseAuth
                                            .instance.currentUser!.uid;
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(uid)
                                            .collection('Milk')
                                            .doc()
                                            .set({
                                          'date': _milkingDateController.text,
                                          'time': selectedTime,
                                          'quantity':
                                              _milkQuantityController.text,
                                        });
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: SvgPicture.asset(
                          'assets/milk (1).svg',
                          width: 30,
                          height: 30,
                          color: Theme.of(context).primaryColor,
                        ),
                        label: const Text('Milk'),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final _expenseDateController =
                              TextEditingController();
                          final _expenseNameController =
                              TextEditingController();
                          final _expenseCostController =
                              TextEditingController();
                          final _notesController = TextEditingController();
                          final _paymentType = [
                            'Cash',
                            'Card',
                            'Mobile Money'
                          ]; // Example payment options
                          String selectedPaymentType =
                              _paymentType[0]; // Default selection

                          await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Record Expense'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize:
                                        MainAxisSize.min, // Avoid overflow
                                    children: [
                                      TextFormField(
                                        controller: _expenseDateController,
                                        decoration: const InputDecoration(
                                          labelText:
                                              'Expense Date (YYYY-MM-DD)',
                                        ),
                                        keyboardType: TextInputType
                                            .datetime, // Keyboard for date input
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter an expense date.';
                                          }
                                          return null;
                                        },
                                      ),
                                      TextFormField(
                                        controller: _expenseNameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Expense Name',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter the expense name.';
                                          }
                                          return null;
                                        },
                                      ),
                                      TextFormField(
                                        controller: _expenseCostController,
                                        decoration: const InputDecoration(
                                          labelText: 'Expense Cost',
                                        ),
                                        keyboardType: TextInputType
                                            .number, // Keyboard for numeric input
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter the expense cost.';
                                          }
                                          return null;
                                        },
                                      ),
                                      DropdownButtonFormField<String>(
                                        value: selectedPaymentType,
                                        hint: const Text('Select Payment Type'),
                                        items: _paymentType
                                            .map((type) =>
                                                DropdownMenuItem<String>(
                                                  value: type,
                                                  child: Text(type),
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedPaymentType = value!;
                                          });
                                        },
                                      ),
                                      // Add more fields based on your requirements (replace with actual widgets)
                                      TextFormField(
                                        controller:
                                            _notesController, // Add a notes controller
                                        decoration: const InputDecoration(
                                          labelText: 'Notes (Optional)',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (_expenseDateController.text.isNotEmpty &&
                                          _expenseNameController
                                              .text.isNotEmpty &&
                                          _expenseCostController
                                              .text.isNotEmpty) {
                                        final uid = FirebaseAuth
                                            .instance.currentUser!.uid;
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(uid)
                                            .collection('Expenses')
                                            .doc()
                                            .set({
                                          'date': _expenseDateController.text,
                                          'name': _expenseNameController.text,
                                          'cost': _expenseCostController.text,
                                          'paymentMethod': selectedPaymentType,
                                          'notes':
                                              _notesController.text.isNotEmpty
                                                  ? _notesController.text.trim()
                                                  : '',
                                        });
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: SvgPicture.asset(
                          'assets/expense.svg',
                          width: 30,
                          height: 30,
                          color: Theme.of(context).primaryColor,
                        ),
                        label: const Text('Expenses'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              // Summary Cards (Replace with actual data and widgets)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Cattle',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5.0),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(AuthService().currentUser?.uid)
                                .collection('Milk')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text(
                                    'Error: ${snapshot.error}'); // Handle errors
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator(); // Show loading indicator
                              }

                              // Calculate total cost
                              int count = 0;

                              snapshot.data!.docs.forEach((doc) {
                                count += 1;
                              });

                              return Text(
                                '$count',
                                style: const TextStyle(fontSize: 20.0),
                              );
                            },
                          ),
                        ],
                      ),
                      SvgPicture.asset(
                        'assets/total_cow.svg',
                        width: 45,
                        height: 45,
                        color: Colors.black,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Average Milk Production (L)',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5.0),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(AuthService().currentUser?.uid)
                                .collection('Milk')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text(
                                    'Error: ${snapshot.error}'); // Handle errors
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator(); // Show loading indicator
                              }

                              // Calculate total cost
                              double count = 0;
                              double totalCost =
                                  0.0; // Reset totalCost on each snapshot
                              snapshot.data!.docs.forEach((doc) {
                                final cost =
                                    double.parse(doc['quantity'] as String);
                                totalCost += cost;
                                count += 1;
                              });

                              return Text(
                                '${totalCost / count}',
                                style: const TextStyle(fontSize: 20.0),
                              );
                            },
                          ),
                        ],
                      ),
                      SvgPicture.asset(
                        'assets/milk (1).svg',
                        width: 45,
                        height: 45,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Expenses (UGX)',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5.0),
                            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(AuthService().currentUser?.uid)
                                  .collection('Expenses')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text(
                                      'Error: ${snapshot.error}'); // Handle errors
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator(); // Show loading indicator
                                }

                                // Calculate total cost
                                double totalCost =
                                    0.0; // Reset totalCost on each snapshot
                                snapshot.data!.docs.forEach((doc) {
                                  final cost =
                                      double.parse(doc['cost'] as String);
                                  totalCost += cost;
                                });

                                return Text(
                                  '$totalCost',
                                  style: const TextStyle(fontSize: 20.0),
                                );
                              },
                            ),
                          ],
                        ),
                        SvgPicture.asset(
                          'assets/expense.svg',
                          width: 45,
                          height: 45,
                          color: Colors.black,
                        )
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
