import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jhumo/moduls/controller/collaboration_controller.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class CollaborationPage extends StatelessWidget {
  CollaborationPage({super.key});

  final CollaborationController _collaborationController =
      Get.put(CollaborationController());
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final RxBool autoSync = false.obs;

  @override
  Widget build(BuildContext context) {
    _durationController.text = _collaborationController.timeDuration.toString();

    return Scaffold(
      backgroundColor: Colors.transparent, // Let MainPage gradient show through
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    "Collaboration",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28, // Reduced from 32
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Experimental",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 8),
              Text(
                "Listen together with friends in real-time.",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Colors.white54,
                ),
              ),
              SizedBox(height: 32),

              GetBuilder<CollaborationController>(
                  init: CollaborationController(),
                  builder: (context) {
                    return Column(
                      children: [
                        // HOST SECTION
                        _buildSectionContainer(
                          title: "Host a Session",
                          child: Column(
                            children: [
                              Text(
                                "Your Session Code",
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 16),

                              // Code Display
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(
                                      text: _collaborationController.id ?? ""));
                                  Get.snackbar("Copied",
                                      "Session code copied to clipboard",
                                      backgroundColor: Colors.white24,
                                      colorText: Colors.white);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 24),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _collaborationController.id
                                                  ?.split("")
                                                  .join("   ") ??
                                              "...",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Icon(Icons.copy_rounded,
                                          color: Colors.white54, size: 20),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: 24),

                              // Toggle Switch
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Enable Hosting",
                                      style: TextStyle(
                                          fontFamily: 'Inter',
                                          color: Colors.white,
                                          fontSize: 15),
                                    ),
                                    Switch.adaptive(
                                        value: _collaborationController.status,
                                        activeColor: Colors.white,
                                        activeTrackColor: Colors.white24,
                                        onChanged: (v) {
                                          _collaborationController
                                              .setStatusOfSync(v);
                                        }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white10)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text("OR JOIN",
                                  style: TextStyle(
                                      color: Colors.white24,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Expanded(child: Divider(color: Colors.white10)),
                          ],
                        ),
                        SizedBox(height: 24),

                        // JOIN SECTION
                        _buildSectionContainer(
                          title: "Join a Session",
                          child: Column(
                            children: [
                              // Input Code
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white10),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 4),
                                child: TextField(
                                  controller: _controller,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Inter',
                                      fontSize: 16),
                                  decoration: InputDecoration(
                                    hintText: "Enter session code",
                                    hintStyle: TextStyle(color: Colors.white24),
                                    border: InputBorder.none,
                                    icon: Icon(Icons.vpn_key_rounded,
                                        color: Colors.white24),
                                  ),
                                ),
                              ),

                              SizedBox(height: 16),

                              // Delay Adjustment
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Sync Delay (ms)",
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontFamily: 'Inter',
                                                fontSize: 13)),
                                        Text(
                                            "${_collaborationController.timeDuration.round()} ms",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    SfSlider(
                                      min: 0.0,
                                      max: 900.0,
                                      value: _collaborationController
                                          .timeDuration
                                          .toDouble(),
                                      interval: 100,
                                      activeColor: Colors.white,
                                      inactiveColor: Colors.white10,
                                      onChanged: (dynamic value) {
                                        _collaborationController
                                            .timeDurationSet(value.round(),
                                                _controller.text);
                                        _durationController.text =
                                            value.round().toString();
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 16),

                              // Auto Sync Toggle
                              Obx(() => Container(
                                    margin: EdgeInsets.only(bottom: 24),
                                    child: Row(
                                      children: [
                                        Transform.scale(
                                          scale: 0.8,
                                          child: Switch(
                                            value: autoSync.value,
                                            activeColor: Colors.white,
                                            onChanged: (v) {
                                              if (_collaborationController
                                                      .autoSync !=
                                                  null) {
                                                autoSync.value =
                                                    _collaborationController
                                                        .onAutoSyncClick(v);
                                              } else {
                                                Get.snackbar("Required",
                                                    "Please enter a valid code first",
                                                    colorText: Colors.white,
                                                    backgroundColor: Colors
                                                        .redAccent
                                                        .withOpacity(0.2));
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text("Auto Sync",
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontFamily: 'Inter')),
                                      ],
                                    ),
                                  )),

                              // Sync Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_controller.text.isNotEmpty) {
                                      _collaborationController
                                          .onClientSync(_controller.text);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    "Sync Now",
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
              SizedBox(height: 100), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer(
      {required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 24),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
