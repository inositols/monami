import '../constants/app_image.dart';

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
    imageUrl: AppImage.jessica,
    title: 'Discover Trend',
    description: '',
  ),
  Slide(
    imageUrl: AppImage.jessica1,
    title: 'Discover Fashions',
    description: '',
  ),
];
