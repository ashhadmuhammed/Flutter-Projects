import 'package:flutter/material.dart';
import 'NavPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
 

  runApp(const MyApp());
}
void _goToHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage(title: '',)),
    );
  }


// void main(){
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Dem',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<User?> _handleSignIn() async {
  try {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      // The user canceled the sign-in process
      return null;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Try to sign in with the Google credentials
    final UserCredential authResult = await _auth.signInWithCredential(credential);
    final User? user = authResult.user;

    if (user != null) {
      // Check if the user is new (just signed up)
      if (authResult.additionalUserInfo?.isNewUser == true) {
        // Perform signup logic here
        // For example, you can add the user to your database or perform additional setup
        // Note: You might need to adjust this part based on your specific backend/database setup
        print('User signed up with Google: ${user.displayName}');
      } else {
        // User already exists, perform login logic if needed
        print('User logged in with Google: ${user.displayName}');
      }
    }

    return user;
  } catch (error) {
    print('Error during Google Sign-In: $error');
    return null;
  }
}


  Future<User?> _handleEmailSignIn() async {
    try {
      final UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      final User? user = authResult.user;
      return user;
    } catch (error) {
      print('Error during Email Sign-In: $error');
      return null;
    }
  }


    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
           
            const SizedBox(height: 16.0),
            // Email/Password Sign-In
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // Sign in with email/password
                User? user = await _handleEmailSignIn() ;
                if (user != null) {
                  _goToHomePage(context);
                  
                  print('Email Sign-In successful: ${user.email}');
                } else {
                  print('Email Sign-In failed');
                }
              },
              child: Text('Sign in with Email'),
            ),
             const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _goToHomePage(context),
              child: const Text('Home'),
            ),
             ElevatedButton(
              onPressed: () async {
                // Sign in with Google
                User? user = await _handleSignIn();
                if (user != null) {
                  _goToHomePage(context);
                  print('Google Sign-In successful: ${user.displayName}');
                } else {
                  print('Google Sign-In failed');
                }
              },
              
              child: Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }
}