import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/custom_widgets/custom_button.dart';
import 'package:monami/custom_widgets/custom_textfield.dart';
import 'package:monami/src/features/auth/providers/auth_state_provider.dart';
import 'dart:developer' as devtools show log;

import 'package:monami/src/features/image_upload/helpers/image_upload_helper.dart';
import 'package:monami/src/features/image_upload/models/file_type.dart';
import 'package:monami/state/post_settings/providers/post_settings_provider.dart';
import 'package:monami/views/create_post/create_new_post.dart';
import 'package:monami/views/dialogs/alert_dialog_model.dart';
import 'package:monami/views/dialogs/logout.dart';

import 'onboarding/components/constants/app_color.dart';
import 'onboarding/components/constants/app_image.dart';
import 'user_post/user_post_view.dart';

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
  late ScrollController _scrollController;
  // bool fixedScroll = false;

  double _containerHeight = 120.0;
  double _containerWidth = 120.0;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_smoothScrollToTop);

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  _onScroll() {
    setState(() {
      // * Update the container height based on scroll position
      _containerHeight = 120.0 - _scrollController.offset.clamp(0.0, 60.0);
      _containerWidth = 120.0 - _scrollController.offset.clamp(0.0, 60.0);
    });
  }

  _smoothScrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(microseconds: 300),
      curve: Curves.ease,
    );
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
                        leading: CircleAvatar(),
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
                              Icon(Icons.menu)
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
                          color: AppColor.button),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(8),
                            width: MediaQuery.sizeOf(context).width / 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text("new \ncollection".toUpperCase()),
                                const SizedBox(
                                  width: 100,
                                  height: 40,
                                  child: CustomButton(
                                    text: "Shop Now",
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(child: Image.asset(AppImage.nina1))
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
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            "View All",
                            style: GoogleFonts.roboto(
                              color: Colors.grey,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(20),
                    Container(
                      alignment: Alignment.centerLeft,
                      height: 40,
                      child: TabBar(
                        indicatorPadding: EdgeInsets.zero,
                        unselectedLabelColor: const Color(0xffFFB778),
                        isScrollable: true,
                        indicatorSize: TabBarIndicatorSize.tab,
                        controller: _tabController,
                        indicator: BoxDecoration(
                            color: AppColor.button,
                            borderRadius: BorderRadius.circular(10)),
                        labelColor: const Color(0xffFFD7B4),
                        tabs: const [
                          Tab(
                            text: "All",
                          ),
                          Tab(
                            text: "Shoes",
                          ),
                          Tab(
                            text: "Caps",
                          ),
                          Tab(
                            text: "Dresses",
                          ),
                          Tab(
                            text: "Following",
                          ),
                        ],
                      ),
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
    );
  }
}
