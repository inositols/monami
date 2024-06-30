import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/presentation/widgets/custom_button.dart';
import 'package:monami/src/presentation/widgets/custom_textfield.dart';
import 'package:monami/src/features/image_upload/helpers/image_upload_helper.dart';
import 'package:monami/src/features/image_upload/models/file_type.dart';
import 'package:monami/src/data/state/post_settings/providers/post_settings_provider.dart';
import 'package:monami/src/utils/constants/app_colors.dart';
import 'package:monami/src/utils/constants/app_images.dart';

import 'dart:developer' as devtools show log;

import '../create_post/create_new_post.dart';

import '../user_post/user_post_view.dart';
import 'component/tabs_item.dart';

extension Log on Object {
  void log() => devtools.log(toString());
}

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, value) {
          return [
            SliverToBoxAdapter(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                child: Column(
                  children: [
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: const CircleAvatar(
                          backgroundColor: AppColor.blackColor,
                        ),
                        title: Text(
                          "Good Morning",
                          style: GoogleFonts.montserrat(
                            color: Colors.grey,
                            fontSize: 22,
                          ),
                        ),
                        subtitle: Text(
                          "Okama Innocent",
                          style: GoogleFonts.lato(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        trailing: const SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              Icon(Icons.notifications),
                              SizedBox(
                                width: 40,
                              ),
                              Icon(
                                Icons.menu,
                                color: AppColor.blackColor,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      height: 40,
                      child: const CustomTextfield(
                        prefixIcon: Icon(Icons.search),
                        // hintText: "Search",
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: 150,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(12),
                            width: MediaQuery.sizeOf(context).width / 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "new \ncollection".toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(color: Colors.white),
                                ),
                                SizedBox(
                                  width: 100,
                                  height: 40,
                                  child: CustomButton(
                                    radius: 8,
                                    text: "Shop Now",
                                    color: AppColor.whiteColor,
                                    textColor: AppColor.blackColor,
                                    onPressed: () {},
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(child: Image.asset(AppImage.cap1))
                        ],
                      ),
                    ),
                    const Gap(15),
                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Categories",
                            style: GoogleFonts.lato(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            "View All",
                            style: GoogleFonts.lato(
                              color: Colors.grey,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(20),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.only(left: 0, right: 10),
                      child: TabBar(
                          tabAlignment: TabAlignment.start,
                          unselectedLabelColor: AppColor.blackColor,
                          dividerColor: Colors.transparent,
                          isScrollable: true,
                          indicatorSize: TabBarIndicatorSize.label,
                          controller: _tabController,
                          indicator: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12)),
                          labelColor: AppColor.whiteColor,
                          tabs: tabItems
                              .map((tabs) => Tab(
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.only(
                                          left: 20, right: 20),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.black, width: 1)),
                                      child: Align(
                                          alignment: Alignment.center,
                                          child: Text(tabs.title)),
                                    ),
                                  ))
                              .toList()),
                    )
                  ],
                ),
              ),
            )
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            UserPostView(),
            UserPostView(),
            UserPostView(),
            UserPostView(),
            UserPostView(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
          onPressed: () async {
            final imageFile = await ImagePickerHelper.pickerImageFromGallery();
            if (imageFile == null) {
              return;
            }
            ref.refresh(postSettingProvider);
            if (!mounted) {
              return;
            }
            Navigator.of(
              context,
            ).push(MaterialPageRoute(
                builder: (_) => CreateNewPostView(
                      fileToPost: imageFile,
                      fileType: FileType.image,
                    )));
          },
          child: const Icon(Icons.add_circle)),
    );
  }
}
