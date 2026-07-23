import "package:crud_todo/home_page.dart";
import "package:crud_todo/login.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String name = "", email = "", password = "";
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  registration() async {
    if (password != null) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("Registered Successfuly!!!"),
          ),
        );
        name = nameController.text;
        await userCredential.user!.updateDisplayName(name);
        Navigator.pushReplacement(
          //to not allow user to return back to sign up page by clicking back button
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } on FirebaseException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color.fromARGB(255, 242, 86, 75),
              content: Text(
                "Password provided is too weak!!!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          );
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color.fromARGB(255, 253, 173, 68),
              content: Text(
                "Account already exists!!!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF209cff), Color(0xFF68e0cf)],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 3,
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 60, left: 30, right: 30),
              child: Column(
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/icons8-add-user-male-94.png',
                    ),
                  ),
                  SizedBox(height: 30),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Card(
                      elevation: 2.5,
                      child: Container(
                        width: MediaQuery.of(context).size.width,

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 20.0,
                            left: 20,
                            right: 20,
                          ),
                          child: Form(
                            key: _formkey,
                            child: Column(
                              children: [
                                Text(
                                  "Sign up",
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 30),
                                TextFormField(
                                  controller: nameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please Enter name";
                                    } else
                                      return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Name",
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                ),
                                SizedBox(height: 30),
                                TextFormField(
                                  controller: emailController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please Enter Email";
                                    } else
                                      return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Email",

                                    prefixIcon: Icon(Icons.mail),
                                  ),
                                ),
                                SizedBox(height: 30),
                                TextFormField(
                                  controller: passwordController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please Enter Password";
                                    } else
                                      return null;
                                  },
                                  obscureText: true,
                                  obscuringCharacter: String.fromCharCode(
                                    42,
                                  ), //to make the obscuring text in ***** format
                                  decoration: InputDecoration(
                                    hintText: "Password",

                                    prefixIcon: Icon(Icons.password_rounded),
                                  ),
                                ),
                                SizedBox(height: 20),

                                SizedBox(height: 55),
                                Material(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    splashColor: const Color.fromARGB(
                                      255,
                                      0,
                                      182,
                                      6,
                                    ),

                                    onTap: () async {
                                      if (_formkey.currentState!
                                          .validate()) //to check that all the validator are true or not
                                      {
                                        setState(() {
                                          email = emailController.text;
                                          name = nameController.text;
                                          password = passwordController.text;
                                        });
                                      }
                                      registration();
                                    },
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        color: Color.fromARGB(96, 32, 155, 255),
                                      ),

                                      child: Center(
                                        child: Text(
                                          "SIGN UP",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 45),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          " Login",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
