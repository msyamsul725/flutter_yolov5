import 'package:flutter/material.dart';
import 'package:hyper_ui/module/dashboard/widget/image_file.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../state_util.dart';
import '../controller/dashboard_controller.dart';
import '../widget/camera_detection.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  Widget build(context, DashboardController controller) {
    controller.view = this;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  "assets/image/bg.png",
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.4,
                  fit: BoxFit.fill,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 260, left: 20),
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        54.0,
                      ),
                      topRight: Radius.circular(
                        54.0,
                      ),
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraint) {
                      List menus = [
                        {
                          "icon": MdiIcons.panorama,
                          "label": "Photo",
                          "onTap": () {
                            Get.to(const HomeScreen());
                          },
                        },
                        {
                          "icon": MdiIcons.folder,
                          "label": "File",
                          "onTap": () {
                            Get.to(ImageFile());
                          },
                        },
                        {
                          "icon": MdiIcons.database,
                          "label": "Dataset",
                          "onTap": () {},
                        },
                        {
                          "icon": MdiIcons.information,
                          "label": "Information",
                          "onTap": () {},
                        },
                      ];

                      return Wrap(
                        spacing: 48,
                        runSpacing: 48,
                        children: List.generate(
                          menus.length,
                          (index) {
                            var item = menus[index];

                            var size = constraint.biggest.width / 4;

                            return Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x19000000),
                                    blurRadius: 24,
                                    offset: Offset(0, 11),
                                  ),
                                ],
                              ),
                              width: 160,
                              height: 160,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.blueGrey,
                                  animationDuration:
                                      const Duration(milliseconds: 1000),
                                  backgroundColor: Colors.transparent,
                                  splashFactory: InkSplash.splashFactory,
                                  shadowColor: Colors.transparent,
                                  elevation: 0.0,
                                ),
                                onPressed: () => item["onTap"](),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      item['icon'],
                                      size: 56.0,
                                    ),
                                    const SizedBox(
                                      height: 4.0,
                                    ),
                                    Text(
                                      "${item["label"]}",
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.blueGrey,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<DashboardView> createState() => DashboardController();
}
