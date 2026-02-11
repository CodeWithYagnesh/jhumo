import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jhumo/moduls/model/service.dart';
import 'package:jhumo/moduls/model/themer.dart';

class MusicTile extends StatelessWidget {
  final Result rs;
  const MusicTile({super.key, required this.rs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Hero(
            tag: rs,
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  image: DecorationImage(
                      image: NetworkImage(
                          rs.image != null && rs.image!.length > 1
                              ? rs.image![1].url ?? ''
                              : 'https://placeholder.com/image.png'),
                      fit: BoxFit.cover)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    clipBehavior: Clip.hardEdge,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )),
          Text(
            rs.name ?? '',
            overflow: TextOverflow.ellipsis,
            style: Get.textTheme.titleMedium,
          ),
          Text(
          rs.artists!.all!=null ? rs.artists!.all!.first.name ?? '' : '',
            overflow: TextOverflow.ellipsis,
            style: Get.textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
