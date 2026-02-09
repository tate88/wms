// ignore: file_names
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:WMS/constants/constant.dart';
import 'package:WMS/constants/pref_data.dart';
import 'package:WMS/constants/size_config.dart';
import 'package:WMS/constants/widget_utils.dart';
import 'package:WMS/constants/color_data.dart';
import 'package:WMS/ui/home/home_screen.dart';
import '../login/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SplashScreen();
  }
}

class _SplashScreen extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 2),
      () {
        PrefData.isLogIn().then((value) {
          if (value) {
            Constant.sendToScreen(HomeScreen(), context);
          } else {
          

            Constant.sendToScreen(const LoginScreen(), context);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double screenHeight = SizeConfig.safeBlockVertical! * 100;

    double iconSize = Constant.getPercentSize(screenHeight, 10);

    return WillPopScope(
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                    padding:
                        EdgeInsets.all(Constant.getPercentSize(iconSize, 25)),
                    child:
                        getSvgImage("logo_img.svg", iconSize, color: AppColors.textDark)
                    // Image.asset(
                    //   Constant.assetImagePath + "logo_img.png",
                    //   width: iconSize,
                    //   height: iconSize,
                    //   fit: BoxFit.fill,
                    //   color: fontBlack,
                    // ),
                    ),
                getCustomText("ScotPHY", AppColors.textDark, 1, TextAlign.center,
                    FontWeight.w900, Constant.getPercentSize(screenHeight, 5.5))
              ],
            ),
          ),
        ),
        onWillPop: () async {
          Constant.backToFinish(context);
          return false;
        });
  }
}
