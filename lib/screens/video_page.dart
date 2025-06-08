import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("잘잘법 영상 목록")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService.fetchVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("영상을 불러올 수 없습니다."));
          }

          final videos = snapshot.data!;

          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Card(
                margin: EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Image.network(
                    video['thumbnail'],
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                  title: Text(video['title']),
                  subtitle: Text(
                    video['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    final url =
                        'https://www.youtube.com/watch?v=${video['videoId']}';
                    launchUrl(Uri.parse(url));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
