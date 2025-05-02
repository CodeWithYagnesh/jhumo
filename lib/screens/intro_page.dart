import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jhumo/components/button.dart';
import 'package:jhumo/moduls/controller/theme_controller.dart';
import 'package:jhumo/moduls/model/themer.dart';
import 'package:jhumo/screens/intro_page2.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class IntroPage extends StatelessWidget {
  IntroPage({super.key});
  var _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          //   gradient: _themeController.isDark
          //       ? Themer.gradientDark
          //       : Themer.gradientLight,
          image: DecorationImage(
              image: NetworkImage(
                  "https://images.pexels.com/photos/2147029/pexels-photo-2147029.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
              fit: BoxFit.cover),
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
                    "jhumo",
                    style: Get.textTheme.displayLarge!
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 100),
                    colors: Get.isDarkMode
                        ? Themer.gradientDark.colors
                        : Themer.gradientLight.colors,
                  ),
                  GradientText(
                    "With",
                    style: Get.textTheme.displaySmall!.copyWith(fontSize: 100),
                    colors: Get.isDarkMode
                        ? Themer.gradientDark.colors
                        : Themer.gradientLight.colors,
                  ),
                  Row(
                    children: [
                      Text("Music",
                          style: Get.textTheme.displayLarge!.copyWith(
                              fontWeight: FontWeight.bold, fontSize: 100)),
                      GradientText(
                        ".",
                        style: Get.textTheme.displayLarge!.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 100),
                        colors: Get.isDarkMode
                            ? Themer.gradientDark.colors
                            : Themer.gradientLight.colors,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                          
                          color: Get.isDarkMode ? Themer.light1.withOpacity(0.5) : Themer.dark1.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(  textCapitalization: TextCapitalization.sentences,
                      maxLength: 10,
                        style: Get.textTheme.bodyMedium!.copyWith(
                          color: Get.isDarkMode ? Themer.dark : Themer.light,
                        ),
                        controller: _nameController,
                        decoration: InputDecoration(

                            hintText: "Enter Name",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.white24)),
                      )),
                  SizedBox(height: 16),
                  // FilledButton(
                  //     style: ButtonStyle(
                  //         backgroundColor: WidgetStatePropertyAll(Themer.main)),
                  //     onPressed: () {
                  //       GetStorage("user").write("name", _nameController.text);
                  //       GetStorage("user").save();
                  //       Get.to(IntroPage2());
                  //     },
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Text("Get Started"),
                  //       ],
                  //     )),
                  TxtButton(
                      onPressed: () {
                        GetStorage("user").write("name", _nameController.text);
                        GetStorage("user").save();
                        Get.to(IntroPage2());
                      },
                      text: "Get Started"),
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
