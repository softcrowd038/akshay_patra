import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentTilePreview extends StatefulWidget {
  const CommentTilePreview(
      {super.key, required this.uuid, required this.comment});
  final String? uuid;
  final String comment;

  @override
  State<CommentTilePreview> createState() => _CommentTilePreviewState();
}

class _CommentTilePreviewState extends State<CommentTilePreview> {
  Map<String, dynamic> profileData = {};
  bool isDeleteVisible = false;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() async {
    await getUsers(widget.uuid!);
  }

  Future<void> getUsers(String uuid) async {
    final url = Uri.parse('$baseUrl/profile/$uuid');
    final sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');

    if (authToken == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $authToken'});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final profile = jsonDecode(response.body)['userProfile'];
        if (profile != null) {
          setState(() {
            profileData = profile;
          });
        }
      } else {
        _handleError(response);
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _handleError(http.Response response) {
    if (response.statusCode == 500) {
      print(response.body);
    } else {
      print('Error: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = profileData['imageurl'];

    return Padding(
      padding: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.height * 0.016,
          0,
          MediaQuery.of(context).size.height * 0.016,
          MediaQuery.of(context).size.height * 0.016),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundImage: imageUrl != null
                        ? NetworkImage('http://192.168.1.2:8080/$imageUrl')
                        : const AssetImage('assets/placeholder_avatar.png')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.height * 0.008),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            imageUrl != null ? profileData['username'] : '',
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.014,
                                color: Colors.grey,
                                fontWeight: FontWeight.w100),
                          ),
                          Text(
                            widget.comment,
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.018,
                                fontWeight: FontWeight.w300),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isDeleteVisible = !isDeleteVisible;
                  });
                },
                child: const Icon(Icons.more_vert),
              ),
            ],
          ),
          if (isDeleteVisible)
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.height * 0.2),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.07,
                width: MediaQuery.of(context).size.height * 0.2,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.height * 0.01,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Delete',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
