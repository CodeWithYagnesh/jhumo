import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
    bool isMobile = Get.width < 750;

    return Scaffold(
      backgroundColor: Color(0xFF121212),
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
                            "https://images.pexels.com/photos/1389429/pexels-photo-1389429.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
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
                      child: isMobile ? SizedBox() : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GradientText(
                            "Music",
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Poppins',
                              height: 1.0,
                            ),
                            colors: [Color(0xFF00DBDE), Color(0xFFFC00FF)],
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
                        ]
                      )
                    ),
                  ),
                ),

                // Right Side (or Bottom on Mobile): Content & Input
                Expanded(
                  flex: isMobile ? 6 : 4,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 30 : 60,
                        vertical: isMobile ? 0 : 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isMobile) ...[
                          GradientText(
                            "Music",
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Poppins',
                              height: 1.0,
                            ),
                            colors: [Color(0xFF00DBDE), Color(0xFFFC00FF)],
                          ),
                          Text(
                            "Languages.",
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                        Text(
                          "Select your preferred music language to get the best recommendations.",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Inter',
                            color: Colors.white60,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 20),

                        // Language Chips
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            padding: EdgeInsets.all(20),
                            child: SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                child: Obx(() => Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  alignment: WrapAlignment.start,
                                  children: languages.map((lang) {
                                    bool isSelected = selectedLanguage.value == lang;
                                    return GestureDetector(
                                      onTap: () => selectedLanguage.value = lang,
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 200),
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(
                                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.white.withOpacity(0.2),
                                                    blurRadius: 10,
                                                    offset: Offset(0, 4),
                                                  )
                                                ]
                                              : [],
                                        ),
                                        child: Text(
                                          lang,
                                          style: TextStyle(
                                            color: isSelected ? Colors.black : Colors.white70,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            fontFamily: 'Inter',
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

                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              GetStorage("user").write("lang", selectedLanguage.value);
                              GetStorage("user").save();
                              Get.offAll(() => MainPage(), transition: Transition.zoom, duration: Duration(milliseconds: 500));
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
                              "Let's Play",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 20 : 0),
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
