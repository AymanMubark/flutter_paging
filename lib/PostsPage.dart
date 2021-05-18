import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_paging/post.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;

class PostPage extends StatefulWidget {
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int limit = 3;
  bool isLoading = false;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<List<Post>> getPosts(int skip) async {
    var response = await http.get(Uri.parse(
        "http://jsonplaceholder.typicode.com/photos?_start=$skip&_limit=$limit"));
    var body = response.body;
    var result = jsonDecode(body);

    return (result as List)
        ?.map(
            (e) => e == null ? null : Post.fromJson(e as Map<String, dynamic>))
        ?.toList();
  }

  load() async {
    try {
      setState(() {
        isLoading = true;
      });
      posts = await getPosts(0);
    } catch (e) {
      print(e);
    }
    setState(() {
      isLoading = false;
    });
    _refreshController.refreshCompleted();
  }

  refresh() async {
    try {
      var newPosts = await getPosts(posts.length);
      if (posts.length > 0) {
        posts.addAll(newPosts);
      }
    } catch (e) {
      print(e);
    }
    setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Posts"),
        centerTitle: true,
      ),
      body: Center(
        child: SmartRefresher(
          physics: BouncingScrollPhysics(),
          enableTwoLevel: false,
          enablePullDown: true,
          enablePullUp: true,
          controller: _refreshController,
          onRefresh: load,
          onLoading: refresh,
          footer: ClassicFooter(
            failedText: "",
            loadStyle: LoadStyle.ShowWhenLoading,
            loadingText: "",
            idleText: "",
            noDataText: "",
            canLoadingText: "",
          ),
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : posts.length == 0
                  ? Center(
                      child: Text("لا توجد بيانات"),
                    )
                  : ListView(
                      children: posts
                          .map((post) => Container(
                                child: Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 300,
                                      child: Image.network(
                                        post.url,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    ListTile(
                                      title: Text(post.title),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
        ),
      ),
    );
  }
}
