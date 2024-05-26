import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:prototype_ss/widgets/product.dart';
import 'package:prototype_ss/widgets/product_page.dart';

var headerStyle = const TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 30,
);

List<String> banners = ['banner1', 'banner2', 'banner3'];

class MainPage extends StatefulWidget{
  const MainPage({super.key});

  @override
  State<MainPage> createState(){
    return _MainPage();
  }
}

class _MainPage extends State<MainPage>{
  late PageController _bannerPageController;
  late Timer _bannerTimer;
  int _currentBannerPage = 0;
  
  @override
  void initState(){
    super.initState();
    _bannerPageController = PageController(initialPage: 0);
    _bannerTimer = Timer.periodic(const Duration(seconds: 7), (Timer timer) { 
      if (_currentBannerPage < banners.length - 1){
        _currentBannerPage++;
      }
      else{
        _currentBannerPage = 0;
      }

      _bannerPageController.animateToPage(
        _currentBannerPage, 
        duration: const Duration(milliseconds: 900), 
        curve: Curves.easeInOut
      );
    });
  }

  @override
  void dispose(){
    super.dispose();
    _bannerTimer.cancel();
    _bannerPageController.dispose();
  }

  @override
  Widget build(BuildContext context){

    double myWidth = MediaQuery.of(context).size.width;
    double myHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center, 
      children: [
        SizedBox(
          width: myWidth,
          height: myHeight * 0.15,
          child: PageView.builder(
            controller: _bannerPageController,
            itemCount: banners.length,
            itemBuilder: (context, index) {
              return Image.asset(
                'assets/images/banners/${banners[index]}.jpg',
                fit: BoxFit.fill,
              );
            },
          )
        ),
        Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 10),
                height: myHeight * 0.1,
                child: Text(
                  'Recommended For You ',
                  style: headerStyle,
                ),
              ),
              const Expanded(
                child: ProductPage(scrollDirection: Axis.horizontal,),
              ),
              Container(
                padding: const EdgeInsets.only(top: 10),
                height: myHeight * 0.1,
                child: Text(
                  'Trending Styles',
                  style: headerStyle,
                ),
              ),
              const Expanded(
                child: ProductPage(scrollDirection: Axis.horizontal,)
              ),
              SizedBox(height: myHeight * 0.12,)
            ],
          )
        )
      ],
    );
  }
}



