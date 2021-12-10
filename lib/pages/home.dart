import 'package:carrotmarket/repository/contents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:carrotmarket/utils/utils.dart';

import 'details.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _currentLocation;
  Contents contents;
  final Map<String, String> locationTypeToString = {
    "ara": "아라동",
    "ora": "오리동",
    "donam": "도남동",
  };

  @override
  void initState() {
    super.initState();
    _currentLocation = "ara";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    contents = Contents();
  }

  Widget _appBarWidget() {
    return AppBar(
      title: GestureDetector(
        onTap: () {
          print("click");
        },
        child: PopupMenuButton<String>(
          offset: Offset(-10, -10),
          shape: ShapeBorder.lerp(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            1,
          ),
          onSelected: (String where) {
            setState(() {
              _currentLocation = where;
            });
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                value: "ara",
                child: Text("아라동"),
              ),
              PopupMenuItem(
                value: "ora",
                child: Text("오라동"),
              ),
              PopupMenuItem(
                value: "donam",
                child: Text("도남동"),
              ),
            ];
          },
          child: Row(
            children: [
              Text(locationTypeToString[_currentLocation]),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
      elevation: 1,
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.tune),
          onPressed: () {},
        ),
        IconButton(
          icon: SvgPicture.asset(
            "assets/svg/bell.svg",
            width: 22,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  _loadContents() {
    return contents.loadContentsFromLocation(_currentLocation);
  }

  _makeDataList(List<Map<String, String>> datas) {
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

  Widget _bodyWidget() {
    return FutureBuilder(
      future: _loadContents(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget(),
      body: _bodyWidget(),
    );
  }
}
