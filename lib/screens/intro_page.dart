import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jhumo/moduls/controller/theme_controller.dart';

import 'package:jhumo/screens/intro_page2.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class IntroPage extends StatelessWidget {
  IntroPage({super.key});
  var _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isMobile = Get.width < 750;

    return Scaffold(
      backgroundColor: Color(0xFF121212), // Clean dark aesthetic
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 1200),
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              children: [
                // Left Side (or Top on Mobile): Branding/Image
                Expanded(
                  flex: isMobile ? 3 : 5,
                  child: Container(
                    margin: isMobile ? EdgeInsets.all(20) : EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      image: DecorationImage(
                        image: NetworkImage(
                            "https://images.pexels.com/photos/1763075/pexels-photo-1763075.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 30,
                          offset: Offset(0, 10),
                        )
                      ]
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ]
                        )
                      ),
                      padding: EdgeInsets.all(30),
                      alignment: Alignment.bottomLeft,
                      child: isMobile ? SizedBox() : GradientText(
                        "Jhumo",
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Poppins',
                          letterSpacing: -1.5,
                        ),
                        colors: [Color(0xFFFF0055), Color(0xFF8800FF)],
                      ),
                    ),
                  ),
                ),

                // Right Side (or Bottom on Mobile): Content & Input
                Expanded(
                  flex: isMobile ? 4 : 4,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 30 : 60,
                        vertical: isMobile ? 10 : 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isMobile)
                           GradientText(
                            "Jhumo",
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Poppins',
                              letterSpacing: -1.0,
                            ),
                            colors: [Color(0xFFFF0055), Color(0xFF8800FF)],
                          ),
                        SizedBox(height: isMobile ? 10 : 0),
                        Text(
                          "Feel the Rhythm.",
                          style: TextStyle(
                            fontSize: isMobile ? 40 : 54,
                            height: 1.1,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Immerse yourself in a world of limitless music. High quality audio, curated playlists, and a stunning experience.",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Inter',
                            color: Colors.white60,
                            height: 1.6,
                          ),
                        ),
                        SizedBox(height: 50),

                        // Form Section (Google Aesthetic: clean lines, simple shapes)
                        Text(
                          "Get Started",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            color: Colors.white54,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 16),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: TextField(
                            controller: _nameController,
                            style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Inter'),
                            cursorColor: Color(0xFFFF0055),
                            textCapitalization: TextCapitalization.words,
                            maxLength: 15,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                              hintText: "What should we call you?",
                              hintStyle: TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                              counterText: "",
                              suffixIcon: Icon(Icons.person_outline_rounded, color: Colors.white54),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
