import 'package:animated_search_bar/animated_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:mgtrisque_visitepreliminaire/screens/login_screen.dart';
import 'package:mgtrisque_visitepreliminaire/screens/affaires_screen.dart';
import 'package:mgtrisque_visitepreliminaire/screens/sync_screen.dart';
import 'package:mgtrisque_visitepreliminaire/screens/visite_screen.dart';
import 'package:mgtrisque_visitepreliminaire/services/affaires.dart';
import 'package:mgtrisque_visitepreliminaire/services/auth.dart';
import 'package:mgtrisque_visitepreliminaire/services/global_provider.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _advancedDrawerController = AdvancedDrawerController();
    int _currentIndex = 1;
    final List<Widget> bottomBarWidgets = [
      SyncScreen(),
      AffairesScreen(),
      VisiteScreen(),
    ];
    final List<String> bottomBarNames = [
      'Synchronisation',
      'Affaires',
      'Visite Préliminaire'
    ];
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final String _screenTitle = Provider.of<GlobalProvider>(context, listen: false).screenTitle;
    return AdvancedDrawer(
      backdropColor: Colors.teal,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      openScale: 1.0,
      openRatio: 0.65,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xffe4e9f9),
        appBar: AppBar(
          title: Text('${Provider.of<GlobalProvider>(context, listen: false).screenTitle}'),
          titleSpacing: 0.0,
          leading: IconButton(
            onPressed: _handleMenuButtonPressed,
            icon: ValueListenableBuilder<AdvancedDrawerValue>(
              valueListenable: _advancedDrawerController,
              builder: (_, value, __) {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  child: Icon(
                    value.visible ? Icons.clear : Icons.menu,
                    key: ValueKey<bool>(value.visible),
                  ),
                );
              },
            ),
          ),
          actions: [
            if(_screenTitle == 'Affaires')
              Container(
                width: MediaQuery.of(context).size.width*1/2,
                child: AnimatedSearchBar(
                    label: "Cherchez une affaire",
                    controller: _searchController,
                    labelStyle: TextStyle(fontSize: 16),
                    searchStyle: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    textInputAction: TextInputAction.done,
                    searchDecoration: InputDecoration(
                      hintText: "Search",
                      alignLabelWithHint: true,
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      print("value on Change");
                      Provider.of<Affaires>(context, listen: false).setfoundAffaires = value;
                    },
                    onFieldSubmitted: (value) {
                      print("value on Field Submitted");
                      Provider.of<Affaires>(context, listen: false).setfoundAffaires = value;
                    }
                ),
              ),
          ],
        ),
        bottomNavigationBar: SalomonBottomBar(
          margin: EdgeInsets.symmetric(horizontal: 30.0),
          currentIndex: _currentIndex,
          onTap: (i) {
              setState(
                () => _currentIndex = i,
              );
              Provider.of<GlobalProvider>(context, listen: false).setScreenTitle = bottomBarNames[i];
            },
          items: [
            /// Synchronisation
            SalomonBottomBarItem(
              icon: Image.asset(
                'assets/images/syncing.png',
              ),
              title: Text("Synchronisation"),
              selectedColor: Colors.blueAccent,
            ),

            /// Affaires
            SalomonBottomBarItem(
              icon: Image.asset(
                'assets/images/affaires.png',
              ),
              title: Text("Affaires"),
              selectedColor: Colors.purple,
            ),

            /// Visite preliminaire
            SalomonBottomBarItem(
              icon: Image.asset(
                'assets/images/visite.png',
              ),
              title: Text("Visite"),
              selectedColor: Colors.redAccent,
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: bottomBarWidgets,
        ),
      ),
      drawer: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: ListTileTheme(
            textColor: Colors.white,
            iconColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 128.0,
                  height: 128.0,
                  margin: const EdgeInsets.only(
                    top: 24.0,
                    bottom: 34.0,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: Image.network(
                    'https://thumbs.dreamstime.com/b/businessman-icon-vector-male-avatar-profile-image-profile-businessman-icon-vector-male-avatar-profile-image-182095609.jpg',
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(
                    bottom: 64.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        '${Provider.of<Auth>(context, listen: false).user?.Nom} ${Provider.of<Auth>(context, listen: false).user?.Prenom}',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                ),
                ListTile(
                  onTap: () {},
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                ),
                ListTile(
                  onTap: () {},
                  leading: Icon(Icons.account_circle_rounded),
                  title: Text('Profile'),
                ),
                ListTile(
                  onTap: () {},
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
                ListTile(
                  onTap: () async {
                    await Provider.of<Auth>(context, listen: false).logout();
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                ),
                Spacer(),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 16.0,
                    ),
                    child: Text('CTC Algerie'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }
}
