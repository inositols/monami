import 'package:monami/src/utils/constants/app_images.dart';

class Slide {
  final String imageUrl;
  final String title;
  final String description;

  Slide({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

final slideList = [
  Slide(
    imageUrl: AppImage.headphone1,
    title: 'Discover Trends',
    description: 'Stay ahead with the latest fashion trends and styles',
  ),
  Slide(
    imageUrl: AppImage.headphone2,
    title: 'Discover Trend',
    description: 'Express yourself through the art of fashionism',
  ),
  Slide(
    imageUrl: AppImage.headphone3,
    title: 'Discover Fashions',
    description: 'Find your unique style and make it your own',
  ),
];
