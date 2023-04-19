import 'package:flutter/material.dart';
import 'package:hyper_ui/module/dashboard/view/dashboard_view.dart';
import 'package:just_audio/just_audio.dart';

class BasicMainNavigationView extends StatefulWidget {
  const BasicMainNavigationView({Key? key}) : super(key: key);

  @override
  State<BasicMainNavigationView> createState() =>
      _BasicMainNavigationViewState();
}

class _BasicMainNavigationViewState extends State<BasicMainNavigationView> {
  int selectedIndex = 0;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: selectedIndex,
      child: Scaffold(
        body: IndexedStack(
          index: selectedIndex,
          children: [
            const DashboardView(),
            Container(
              color: Colors.red[100],
            ),
            Container(
              color: Colors.purple[100],
            ),
            Container(
              color: Colors.blue[100],
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          selectedItemColor: Colors.grey[700],
          unselectedItemColor: Colors.grey[500],
          onTap: (index) {
            selectedIndex = index;

            setState(() {});
          },
          items: const [
            BottomNavigationBarItem(
              label: "Home",
              icon: Icon(
                Icons.home,
              ),
            ),
            BottomNavigationBarItem(
              label: "Order",
              icon: Icon(
                Icons.list,
              ),
            ),
            BottomNavigationBarItem(
              label: "Favorite",
              icon: Icon(
                Icons.favorite,
              ),
            ),
            BottomNavigationBarItem(
              label: "Me",
              icon: Icon(
                Icons.person,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
