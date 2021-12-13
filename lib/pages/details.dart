import 'package:carousel_slider/carousel_slider.dart';
import 'package:carrotmarket/componants/manorTemperatureWidget.dart';
import 'package:carrotmarket/repository/contents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:carrotmarket/utils/utils.dart';

class Details extends StatefulWidget {
  final Map<String, String> data;

  const Details({Key key, this.data}) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> with SingleTickerProviderStateMixin {
  final ScaffoldKey = GlobalKey<ScaffoldState>();
  Contents contents;
  Size size;
  List<Map<String, String>> imgList;
  int _current;
  double scrPositionToAlpha = 0;
  ScrollController _controller = ScrollController();
  AnimationController _aniController;
  Animation _colorTween;
  bool isMyFavoriteContent = false;

  @override
  initState() {
    super.initState();
    contents = Contents();
    _aniController = AnimationController(vsync: this);
    _colorTween = ColorTween(begin: Colors.white, end: Colors.black)
        .animate(_aniController);
    _controller.addListener(() {
      setState(() {
        if (_controller.offset >= 255)
          scrPositionToAlpha = 255;
        else if (_controller.offset <= 0)
          scrPositionToAlpha = 0;
        else
          scrPositionToAlpha = _controller.offset;

        _aniController.value = scrPositionToAlpha / 255;
      });
    });

    _loadMyFavoriteContentState();
  }

  _loadMyFavoriteContentState() async {
    bool ck = await contents.isMyFavoriteContents(widget.data["cid"]);
    setState(() {
      isMyFavoriteContent = ck == null ? false : ck;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = MediaQuery.of(context).size;
    _current = 0;
    imgList = [
      {"id": "0", "url": widget.data["image"]},
      {"id": "1", "url": widget.data["image"]},
      {"id": "2", "url": widget.data["image"]},
      {"id": "3", "url": widget.data["image"]},
      {"id": "4", "url": widget.data["image"]},
    ];
  }

  Widget _makeIcon(IconData icon) {
    return AnimatedBuilder(
      animation: _colorTween,
      builder: (context, child) => Icon(
        icon,
        color: _colorTween.value,
      ),
    );
  }

  Widget _appBarWidget() {
    return AppBar(
      backgroundColor: Colors.white.withAlpha(
        scrPositionToAlpha.toInt(),
      ),
      elevation: 0,
      leading: IconButton(
        icon: _makeIcon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: _makeIcon(Icons.share),
          onPressed: () {},
        ),
        IconButton(
          icon: _makeIcon(Icons.more_vert),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _bottomBarWidget() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15,
      ),
      width: size.width,
      height: 55,
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              if (isMyFavoriteContent) {
                await contents.deleteMyFavoriteContent(widget.data["cid"]);
              } else {
                await contents.addMyFavoriteContent(widget.data);
              }
              setState(() {
                isMyFavoriteContent = !isMyFavoriteContent;
              });
              ScaffoldKey.currentState.showSnackBar(
                SnackBar(
                  duration: Duration(milliseconds: 1000),
                  content: Text(isMyFavoriteContent
                      ? "관심 목록에 추가 되었습니다."
                      : "관심 목록에서 제거되었습니다."),
                ),
              );
            },
            child: SvgPicture.asset(
              isMyFavoriteContent
                  ? "assets/svg/heart_on.svg"
                  : "assets/svg/heart_off.svg",
              width: 25,
              height: 25,
              color: Color(0xfff08f4f),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              left: 15,
              right: 10,
            ),
            width: 1,
            height: 40,
            color: Colors.grey.withOpacity(0.3),
          ),
          Column(
            children: [
              Text(
                utils.calcStringToWon(widget.data["price"]),
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Text(
                "가격제안불가",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Color(0xfff08f4f),
                  ),
                  child: Text(
                    "deal for chat",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _makeSliderImage() {
    return Container(
      child: Stack(
        children: [
          Hero(
            tag: widget.data["cid"],
            child: Container(
              child: CarouselSlider(
                options: CarouselOptions(
                  height: size.width,
                  initialPage: 0,
                  enableInfiniteScroll: false,
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  },
                ),
                items: imgList.map(
                  (map) {
                    return Image.asset(
                      map["url"],
                      width: size.width,
                      fit: BoxFit.fill,
                    );
                  },
                ).toList(),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imgList
                  .map(
                    (map) => Container(
                      width: 10,
                      height: 10,
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _current == int.parse(map["id"])
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sellerInfo() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: Image.asset("assets/images/user.png").image,
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "RWAROU",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "제주시 도담동",
              ),
            ],
          ),
          Expanded(
            child: ManorTemperature(
              manorTemp: 37.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _line() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      height: 1,
      color: Colors.grey.withOpacity(0.3),
    );
  }

  Widget _contentsDetail() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 20,
          ),
          Text(
            widget.data["title"],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            "디지털/가전 - 22시간 전",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "선물받은 새상품이고\n상품 꺼내보기만 했습니다\n거래는 직거래만 합니다",
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "채팅 3 - 관심 17 - 조회 297",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Widget _otherCellContents() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "판매자님의 판매 상품",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "모두보기",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyWidget() {
    return CustomScrollView(
      controller: _controller,
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              _makeSliderImage(),
              _sellerInfo(),
              _line(),
              _contentsDetail(),
              _line(),
              _otherCellContents(),
            ],
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            delegate: SliverChildListDelegate(
              List.generate(
                20,
                (index) => Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          color: Colors.grey,
                          height: 120,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "상품제목",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "금액",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ScaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: _appBarWidget(),
      body: _bodyWidget(),
      bottomNavigationBar: _bottomBarWidget(),
    );
  }
}
