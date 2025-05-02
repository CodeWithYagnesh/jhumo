import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jhumo/components/button.dart';
import 'package:jhumo/moduls/controller/theme_controller.dart';
import 'package:jhumo/moduls/model/themer.dart';
import 'package:jhumo/screens/main_page.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class IntroPage2 extends StatelessWidget {
  IntroPage2({super.key});
  var selectedLanguage = 'English'.obs;
  List<String> languages = [
    'English',
    'Spanish',
    'Mandarin',
    'French',
    'German',
    'Japanese',
    'Korean',
    'Italian',
    'Portuguese',
    'Russian',
    'Arabic',
    'Hindi',
    'Bengali',
    'Turkish',
    'Vietnamese',
    'Persian',
    'Dutch',
    'Greek',
    'Swedish',
    'Thai',
    'Hebrew',
    'Czech',
    'Danish',
    'Finnish',
    'Hungarian',
    'Indonesian',
    'Norwegian',
    'Polish',
    'Romanian',
    'Ukrainian'
  ];
  var _themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: Themer.gradientDark.colors,
          // ),
          image: DecorationImage(
            image: NetworkImage(
                "https://images.pexels.com/photos/3756766/pexels-photo-3756766.jpeg?auto=compress&cs=tinysrgb&w=600"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Get.isDarkMode
              ? Themer.dark.withOpacity(0.5)
              : Themer.light.withOpacity(0.5),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Expanded(
            //     child: Row(
            //   children: [
            //     Expanded(
            //       child: Image.asset(
            //         "assets/Frame.png",
            //         fit: BoxFit.cover,
            //       ),
            //     ),
            //   ],
            // )),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GradientText(
                    "Find your favorite",
                    style: Get.textTheme.headlineMedium!.copyWith(fontSize: 70),
                    colors: Get.isDarkMode
                        ? Themer.gradientDark.colors
                        : Themer.gradientLight.colors,
                  ),
                  Row(
                    children: [
                      Text("MUSIC",
                          style: Get.textTheme.headlineMedium!.copyWith(
                              fontSize: 70, fontWeight: FontWeight.bold)),
                      GradientText(
                        ".",
                        style: TextStyle(
                            fontSize: 70, fontWeight: FontWeight.bold),
                        colors: _themeController.isDark
                            ? Themer.gradientDark.colors
                            : Themer.gradientLight.colors,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Music Language:  ",
                            // style: TextStyle(color: Colors.white60, fontSize: 17),
                          ),
                          Obx(() => DropdownButton<String>(
                                // style:
                                //     TextStyle(color: Colors.white, fontSize: 17),
                                value: selectedLanguage.value,
                                dropdownColor: Colors.white,
                                underline: SizedBox(),
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                ),
                                items: languages.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (_) {
                                  selectedLanguage.value = _!;
                                },
                              )),
                        ],
                      )),
                  SizedBox(height: 16),
                  TxtButton(
                      onPressed: () {
                        GetStorage("user")
                            .write("lang", selectedLanguage.value);
                        GetStorage("user").save();
                        Get.offAll(MainPage());
                      },
                      text: "Lat's Play"),
                  // GestureDetector(
                  //   onTap: () {
                  //     GetStorage("user").write("lang", selectedLanguage.value);
                  //     GetStorage("user").save();
                  //     Get.offAll(MainPage());
                  //   },
                  //   child: Container(
                  //     padding: EdgeInsets.symmetric(vertical: 20),
                  //     decoration: BoxDecoration(
                  //         boxShadow: [
                  //           BoxShadow(
                  //               color: Themer.main,
                  //               blurRadius: 20,
                  //               offset: Offset(0, 10))
                  //         ],
                  //         gradient: _themeController.isDark
                  //             ? Themer.gradientDark
                  //             : Themer.gradientLight,
                  //         borderRadius: BorderRadius.circular(10)),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Text(
                  //           "Let's Play",
                  //           style: Get.textTheme.titleMedium!.copyWith(color: Themer.light),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
