import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jhumo/moduls/model/playlists_song.dart' as ps;
import 'package:jhumo/moduls/model/service.dart';

class StreamInfo {
  final String url;
  StreamInfo(this.url);
}

class YoutubeService {
  static final YoutubeService _instance = YoutubeService._internal();
  factory YoutubeService() => _instance;
  YoutubeService._internal();

  String get baseUrl {
    // return "https://yagneshjariwala-music-api.hf.space";
    // return "http://192.168.1.8:8000";
    return "https://music-api.yagnesh.cloud";
  }

  Future<List<Result>> searchSongs(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/search/songs?query=${Uri.encodeComponent(query)}'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => Result.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error searching songs: $e");
    }
    return [];
  }

  Future<List<Result>> searchPlaylists(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/search/playlists?query=${Uri.encodeComponent(query)}'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => Result.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error searching playlists: $e");
    }
    return [];
  }

  Future<ps.PlaylistsSong?> getPlaylistDetails(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/playlist/$id'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return ps.PlaylistsSong.fromJson(data);
      }
    } catch (e) {
      print("Error getting playlist details: $e");
    }
    return null;
  }

  Future<List<Result>> getSuggestedSongs(String videoId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/song/$videoId/related'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => Result.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error getting suggested songs: $e");
    }
    return [];
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/search/suggestions?query=${Uri.encodeComponent(query)}'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => e.toString()).toList();
      }
    } catch (e) {
      print("Error getting search suggestions: $e");
    }
    return [];
  }

  Future<String?> getLyrics(String videoId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/song/$videoId/lyrics'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data is String ? data : null;
      }
    } catch (e) {
      print("Error getting lyrics: $e");
    }
    return null;
  }

  Future<Result?> getSong(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/song/$id'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data != null) {
          return Result.fromJson(data);
        }
      }
    } catch (e) {
      print("Error getting song: $e");
    }
    return null;
  }

  Future<StreamInfo> getAudioStreamInfo(String videoId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/song/$videoId/stream_info'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return StreamInfo(data['url']);
      }
    } catch (e) {
      print("Error getting stream info: $e");
    }
    // Fallback to streaming via our server
    return StreamInfo('$baseUrl/song/$videoId/stream');
  }

  Future<Stream<List<int>>> getStream(StreamInfo info, {int? start, int? end}) async {
    var client = http.Client();
    var request = http.Request('GET', Uri.parse(info.url));

    if (start != null || end != null) {
      String range = 'bytes=${start ?? 0}-${end ?? ""}';
      request.headers['Range'] = range;
    }

    try {
      var response = await client.send(request);
      if (response.statusCode == 200 || response.statusCode == 206) {
        return response.stream;
      }
    } catch (e) {
      print("Error fetching stream: $e");
    }
    return const Stream.empty();
  }

  Future<String?> getAudioUrl(String videoId) async {
    // Instead of resolving the complex youtube stream, we just point
    // to our backend which resolves and proxies it if needed, or returns the yt-dlp URL.
    try {
      final response = await http.get(Uri.parse('$baseUrl/song/$videoId/stream_info'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['url'];
      }
    } catch (e) {
        print("Error getting stream url directly: $e");
    }
    // direct proxy stream url from our API
    return '$baseUrl/song/$videoId/stream';
  }

  void dispose() {
    // Cleanup if needed
  }
}
