import 'package:crud_todo/signUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String email = "";
  TextEditingController emailController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color.fromARGB(255, 153, 201, 71),
          content: Text(
            "Password reset mail has been sent!!!",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color.fromARGB(208, 209, 70, 70),
            content: Text("User not found"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Container(
        child: Column(
          children: [
            SizedBox(height: 70.0),
            Container(
              alignment: Alignment.topCenter,
              child: Text(
                "Password recovery",
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 38),
            Text(
              "Enter your mail",
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              height: 45,
              width: 300,
              child: TextFormField(
                style: TextStyle(color: Colors.white),
                controller: emailController,
                cursorColor: Colors.white,

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter email";
                  } else
                    return null;
                },
                decoration: InputDecoration(
                  hintText: "Email...",
                  focusColor: Colors.white,
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Form(
              key: _formkey,
              child: GestureDetector(
                onTap: () {
                  if (_formkey.currentState!.validate()) {
                    setState(() {
                      email = emailController.text;
                    });
                    resetPassword();
                  }
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  width: MediaQuery.of(context).size.width / 1.3,
                  height: 40,
                  child: Center(
                    child: Text(
                      "Send mail",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 75),
            Row(
              children: [
                SizedBox(width: 60),
                Text(
                  "Don't have an account? ",
                  style: TextStyle(color: Colors.white, fontSize: 16.6),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignUp()),
                    );
                  },
                  child: Text(
                    "Create",
                    style: TextStyle(
                      fontSize: 16.6,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 175, 232, 78),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
