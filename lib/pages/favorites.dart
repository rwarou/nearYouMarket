import 'package:carrotmarket/repository/contents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carrotmarket/utils/utils.dart';

import 'details.dart';

class MyFavoriteContents extends StatefulWidget {
  const MyFavoriteContents({Key key}) : super(key: key);

  @override
  _MyFavoriteContentsState createState() => _MyFavoriteContentsState();
}

class _MyFavoriteContentsState extends State<MyFavoriteContents> {
  Contents contents;

  @override
  void initState() {
    super.initState();
    contents = Contents();
  }

  Widget _appBarWidget() {
    return AppBar(
      title: Text(
        "관심목록",
        style: TextStyle(
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _bodyWidget() {
    return FutureBuilder(
      future: _loadMyFavotieContentList(),
      builder: (BuildContext context, dynamic snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("data error"),
          );
        }
        if (snapshot.hasData) {
          return _makeDataList(snapshot.data);
        }

        return Center(
          child: Text("NONE DATA"),
        );
      },
    );
  }

  Future<List<dynamic>> _loadMyFavotieContentList() async {
    return await contents.loadFavoriteContents();
  }

  _makeDataList(List<dynamic> datas) {
    return ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (BuildContext _context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return Details(
                    data: datas[index],
                  );
                }),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Hero(
                    tag: datas[index]["cid"],
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      child: Image.asset(datas[index]["image"],
                          width: 100, height: 100),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 100,
                      padding: EdgeInsets.only(left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            datas[index]["title"],
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 15),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            datas[index]["location"],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            utils.calcStringToWon(datas[index]["price"]),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SvgPicture.asset(
                                    "assets/svg/heart_off.svg",
                                    width: 13,
                                    height: 13,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(datas[index]["likes"]),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext _context, int index) {
          return Container(
            height: 1,
            color: Colors.black.withOpacity(0.4),
          );
        },
        itemCount: datas.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget(),
      body: _bodyWidget(),
    );
  }
}
