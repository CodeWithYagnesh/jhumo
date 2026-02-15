import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jhumo/components/button.dart';
import 'package:jhumo/moduls/controller/theme_controller.dart';

import 'package:jhumo/screens/intro_page2.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class IntroPage extends StatelessWidget {
  IntroPage({super.key});
  var _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    "https://images.pexels.com/photos/1763075/pexels-photo-1763075.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"), // High quality music conceptual image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 2. Gradient Overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),
          // 3. Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacer(flex: 2),
                  // App Title with Gradient
                  GradientText(
                    "Jhumo",
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Poppins', // Assuming a nice font is available or default falls back gracefully
                      letterSpacing: -2.0,
                    ),
                    colors: [
                      Color(0xFFFF0055),
                      Color(0xFFFF00CC),
                      Color(0xFF8800FF),
                    ], // Vibrant gradient
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Feel the \nRhythm.",
                    style: TextStyle(
                      fontSize: 50,
                      height: 1.1,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 20),
                   Text(
                    "Immerse yourself in a world of limitless music. High quality audio, curated playlists, and a stunning experience.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  Spacer(flex: 3),

                  // Modern Input Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: TextField(
                      controller: _nameController,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      cursorColor: Color(0xFFFF0055),
                      textCapitalization: TextCapitalization.words,
                      maxLength: 15,
                      decoration: InputDecoration(
                        hintText: "What should we call you?",
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                        counterText: "",
                        icon: Icon(Icons.person_outline_rounded, color: Colors.white54),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: TxtButton(
                      onPressed: () {
                        if (_nameController.text.trim().isEmpty) {
                          Get.snackbar(
                            "Name Required",
                            "Please enter your name to continue",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.white10,
                            colorText: Colors.white,
                            margin: EdgeInsets.all(20),
                          );
                          return;
                        }
                        GetStorage("user").write("name", _nameController.text.trim());
                        GetStorage("user").save();
                        Get.to(() => IntroPage2(), transition: Transition.fadeIn, duration: Duration(milliseconds: 500));
                      },
                      text: "Get Started",
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
