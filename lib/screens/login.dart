import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/Firebase_data.dart';

final _auth = FirebaseAuth.instance;

class Login extends StatefulWidget {
  const Login({required this.onLoginStatusChanged, super.key});
  final void Function(bool) onLoginStatusChanged;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _form = GlobalKey();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  bool login = true;
  bool isAuthenticating = false;
  bool isLogin = false;

  void _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      isAuthenticating = true;
    });
    if (login) {
      try {
        final credential = await _auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        widget.onLoginStatusChanged(true);
        Navigator.of(context).pushNamed('/home');
      } on FirebaseAuthException catch (error) {
        if (error.code == 'user-not-found') {}
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Error: ${error.code}'),
          ),
        );
      }
    }
    if (!login) {
      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        widget.onLoginStatusChanged(true);
        DatabaseFirestore()
            .CreateUser(emailController.text, usernameController.text);
        Navigator.of(context).pushNamed('/home');
      } on FirebaseAuthException catch (error) {
        if (error.code == 'user-not-found') {}
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Error: ${error.code}'),
          ),
        );
      }
    }
    setState(() {
      isAuthenticating = false;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bishop',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 340,
                height: (login) ? 240 : 310,
                child: Expanded(
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (!login)
                          TextFormField(
                            controller: usernameController,
                            keyboardType: TextInputType.name,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter valid username';
                              }
                              return null;
                            },
                          ),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter valid Email';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          obscureText: true,
                          controller: passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter valid password';
                            }
                            return null;
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text((login)
                                ? 'Don\'t have an account?'
                                : 'Already have an account?'),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  login = !login;
                                });
                              },
                              child: Text((login) ? 'Sign Up' : 'Login'),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (isAuthenticating) const CircularProgressIndicator(),
                        if (!isAuthenticating)
                          ElevatedButton(
                            onPressed: _submit,
                            child: Text((login) ? 'Login' : 'Sign Up'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  },
                  child: const Text('Continue as Guest'))
            ],
          ),
        ),
      ),
    );
  }
}
