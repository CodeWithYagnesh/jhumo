import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jhumo/moduls/model/service.dart';
import 'package:jhumo/moduls/model/themer.dart';

class RecentMusicTile extends StatelessWidget {
  final Result rs;
  final bool isPlayed;

  const RecentMusicTile({super.key, required this.rs, this.isPlayed = false});

  @override
  Widget build(BuildContext context) {
    // SAFE IMAGE LOGIC
    String imageUrl = "https://c.saavncdn.com/191/Kesariya-From-Brahmastra-Hindi-2022-20220717092820-500x500.jpg";
    if (rs.image != null && rs.image!.isNotEmpty) {
      // Try to get the last image (usually best quality), otherwise first
      imageUrl = rs.image!.last.url ?? rs.image!.first.url ?? imageUrl;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: isPlayed ? Themer.main.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover)),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rs.name ?? "Unknown Title",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Get.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isPlayed ? Themer.main : null),
                ),
                Text(
                  (rs.artists?.primary != null && rs.artists!.primary!.isNotEmpty)
                      ? rs.artists!.primary![0].name ?? "Unknown Artist"
                      : "Unknown Artist",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Get.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (isPlayed) Icon(Icons.graphic_eq, color: Themer.main)
        ],
      ),
    );
  }
}
