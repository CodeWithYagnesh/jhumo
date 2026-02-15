import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jhumo/components/button.dart';
import 'package:jhumo/screens/main_page.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
class IntroPage2 extends StatelessWidget {
  IntroPage2({super.key});
  final selectedLanguage = 'English'.obs;
  final List<String> languages = [
    'English', 'Spanish', 'Mandarin', 'French', 'German', 'Japanese', 'Korean',
    'Italian', 'Portuguese', 'Russian', 'Arabic', 'Hindi', 'Bengali', 'Turkish',
    'Vietnamese', 'Persian', 'Dutch', 'Greek', 'Swedish', 'Thai',
    'Hebrew', 'Czech', 'Danish', 'Finnish', 'Hungarian', 'Indonesian',
    'Norwegian', 'Polish', 'Romanian', 'Ukrainian'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    "https://images.pexels.com/photos/1389429/pexels-photo-1389429.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"), // Different high quality music/party image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 2. Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.95),
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
                  Spacer(flex: 1),
                  // Header
                  GradientText(
                    "Music",
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Poppins',
                      height: 1.0,
                    ),
                    colors: [
                      Color(0xFF00DBDE),
                      Color(0xFFFC00FF),
                    ], // Cool gradient
                  ),
                  Text(
                    "Languages.",
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Select your preferred music language to get the best recommendations.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  Spacer(flex: 1),

                  // Language Chips
                  Expanded(
                    flex: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(16),
                      child: Scrollbar(
                        // thumbVisibility: true,
                        thumbVisibility: false,
                        thickness: 0,
                        radius: Radius.circular(10),
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Obx(() => Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: languages.map((lang) {
                              bool isSelected = selectedLanguage.value == lang;
                              return GestureDetector(
                                onTap: () => selectedLanguage.value = lang,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(colors: [Color(0xFF00DBDE), Color(0xFFFC00FF)])
                                        : null,
                                    color: isSelected ? null : Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(30),
                                    border: isSelected
                                        ? Border.all(color: Colors.transparent)
                                        : Border.all(color: Colors.white24),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: Color(0xFFFC00FF).withOpacity(0.4),
                                              blurRadius: 12,
                                              offset: Offset(0, 4),
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Text(
                                    lang,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          )),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),
                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: TxtButton(
                      onPressed: () {
                        GetStorage("user").write("lang", selectedLanguage.value);
                        GetStorage("user").save();
                        Get.offAll(() => MainPage(), transition: Transition.zoom, duration: Duration(milliseconds: 500));
                      },
                      text: "Let's Play",
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
