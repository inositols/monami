import 'package:monami/src/utils/constants/app_images.dart';

class DiscoverItems {
  final String title;
  final String image;
  final int price;

  DiscoverItems(this.title, this.image, this.price);
}

final discoverList = [
  DiscoverItems('Shoe', AppImage.woman, 30),
  DiscoverItems('Shoe', AppImage.woman1, 100),
  DiscoverItems('Cap', AppImage.cap, 30),
  DiscoverItems('Cap', AppImage.cap1, 100),
  DiscoverItems('Cap', AppImage.cap2, 50),
  DiscoverItems('Cap', AppImage.cap3, 200),
  DiscoverItems('Ring', AppImage.ring, 200),
  DiscoverItems('Ring', AppImage.ring1, 500),
  DiscoverItems('HeadPhones', AppImage.headphone, 300),
  DiscoverItems('HeadPhones', AppImage.headphone2, 300),
  DiscoverItems('HeadPhones', AppImage.headphone3, 300),
];
