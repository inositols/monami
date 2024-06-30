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
    imageUrl: AppImage.yuri,
    title: 'Discover Trends',
    description: '',
  ),
  Slide(
    imageUrl: AppImage.cap3,
    title: 'Discover Trend',
    description: '',
  ),
  Slide(
    imageUrl: AppImage.headphone3,
    title: 'Discover Fashions',
    description: '',
  ),
];
