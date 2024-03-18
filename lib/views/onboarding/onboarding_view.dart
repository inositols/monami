import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monami/views/login/login_view.dart';
import 'components/constants/app_color.dart';
import 'components/model/slide_model.dart';
import 'components/widgets/slide_dots.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.bgColor,
        body: SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 1.5,
                child: PageView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: slideList.length,
                    itemBuilder: (ctx, i) {
                      return Container(
                        color: AppColor.button,
                        padding: const EdgeInsets.all(20),
                        width: double.maxFinite,
                        height: MediaQuery.of(context).size.height / 1.7,
                        child: Image.asset(slideList[i].imageUrl),
                      );
                    }),
              ),
              CustomPaint(
                  painter: BottomClip(),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int i = 0; i < slideList.length; i++)
                              if (i == _currentPage)
                                const SlideDots(true)
                              else
                                const SlideDots(false)
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          slideList[1].title,
                          style: GoogleFonts.montserrat(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text('Express yourself through the art',
                            style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey)),
                        Text(
                          'of the fashionism',
                          style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey),
                        ),
                        const SizedBox(height: 50),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginView()));
                          },
                          child: Stack(
                            children: [
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                    color: AppColor.bgColor,
                                    borderRadius: BorderRadius.circular(50)),
                              ),
                              Positioned(
                                top: 5,
                                left: 5,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: AppColor.button,
                                      borderRadius: BorderRadius.circular(50)),
                                  height: 50,
                                  width: 50,
                                  child: const Icon(
                                    FontAwesomeIcons.arrowRight,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        )
                      ],
                    ),
                  )),
            ],
          ),
        ));
  }
}

class BottomClip extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.white;
    var path = Path();
    path.moveTo(0.0, size.height);
    path.lineTo(0.0, size.height - 260);
    path.quadraticBezierTo(
        size.width / 2, size.height - 350, size.width, size.height - 260);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
