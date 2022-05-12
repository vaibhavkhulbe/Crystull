import 'package:carousel_slider/carousel_slider.dart';
import 'package:crystull/utils/utils.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _current = 0;
  final CarouselController _controller = CarouselController();
  List<String> imgList = ['images/home/1.png', 'images/home/2.png'];

  // this is the image slider for home screen images
  sliderPlugin(images, double height) {
    return CarouselSlider(
      options: CarouselOptions(
        height: height,
        viewportFraction: 1.0,
        enlargeCenterPage: false,
        onPageChanged: (position, reason) {
          setState(
            () {
              _current = position;
            },
          );
        },
        enableInfiniteScroll: false,
      ),
      items: images.map<Widget>((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(i),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0.04),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                sliderPlugin(imgList, getSafeAreaHeight(context) * 0.5),
                Positioned(
                  left: getSafeAreaWidth(context) * 0.5,
                  bottom: getSafeAreaHeight(context) * 0.06,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: imgList.asMap().entries.map(
                      (entry) {
                        return GestureDetector(
                          onTap: () => _controller.animateToPage(entry.key),
                          child: Container(
                            width: 6.0,
                            height: 6.0,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _current == entry.key
                                  ? Colors.lightBlueAccent
                                  : Colors.black54,
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                )
              ],
            ),

            // this is the trending users section
            Container(
              padding: const EdgeInsets.all(8),
              width: getSafeAreaWidth(context),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Trending Crystullites of the week",
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
