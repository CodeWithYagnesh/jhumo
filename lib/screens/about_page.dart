import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient Mesh
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffCA2828).withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xffCA2828).withOpacity(0.4),
                    blurRadius: 100,
                    spreadRadius: 20,
                  )
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                      ),
                      Text(
                        "About",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        // Logo Section
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            border: Border.all(color: Color(0xffCA2828), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xffCA2828).withOpacity(0.3),
                                blurRadius: 40,
                                offset: Offset(0, 10),
                              )
                            ],
                            image: DecorationImage(
                              image: AssetImage("assets/red_logo.png"), // Ensure this asset exists
                              fit: BoxFit.cover
                            )
                          ),
                        ),
                        SizedBox(height: 24),
                        Text(
                          "Jhumo",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          "v2.0.0 • Stable",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Colors.white38,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 40),

                        // Section: Vision
                        _buildSectionHeader("Our Vision"),
                        Text(
                          "Music is the universal language of mankind. At Jhumo, we believe in connecting souls through rhythm and melody without boundaries. Experience music in its purest form.",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            height: 1.6,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 32),

                        // Section: Developer
                        _buildSectionHeader("The Developer"),
                        _buildDeveloperCard(),

                        SizedBox(height: 32),

                        // Links
                        _buildLinkTile(
                          icon: Icons.language_rounded,
                          title: "Website",
                          subtitle: "yagnesh.cloud",
                          url: "https://yagnesh.cloud",
                        ),
                        SizedBox(height: 12),
                        _buildLinkTile(
                          icon: Icons.code_rounded,
                          title: "GitHub",
                          subtitle: "github.com/codewithyagnesh",
                          url: "https://github.com/codewithyagnesh",
                        ),
                        SizedBox(height: 12),
                        _buildLinkTile(
                          icon: Icons.link_rounded,
                          title: "LinkedIn",
                          subtitle: "Yagnesh Jariwala",
                          url: "https://www.linkedin.com/in/yagnesh-jariwala-70273128b/",
                        ),

                        SizedBox(height: 50),
                        Text(
                          "Made with ❤️ in Flutter",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.white24,
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: Color(0xffCA2828),
              borderRadius: BorderRadius.circular(2)
            ),
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xffCA2828),
            child: Text("Y", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CodeWithYagnesh",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Full Stack Developer",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Color(0xffCA2828),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLinkTile({required IconData icon, required String title, required String subtitle, required String url}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => launchUrlString(url),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white70, size: 20),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                         fontFamily: 'Inter',
                         fontSize: 15,
                         fontWeight: FontWeight.w600,
                         color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                         fontFamily: 'Inter',
                         fontSize: 13,
                         color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new_rounded, color: Colors.white24, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
