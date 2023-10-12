import 'package:animated_search_bar/animated_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';

import 'package:mgtrisque_visitepreliminaire/screens/login_screen.dart';
import 'package:mgtrisque_visitepreliminaire/screens/affaires_screen.dart';
import 'package:mgtrisque_visitepreliminaire/screens/sync_screen.dart';
import 'package:mgtrisque_visitepreliminaire/screens/visite_screen.dart';
import 'package:mgtrisque_visitepreliminaire/services/affaires.dart';
import 'package:mgtrisque_visitepreliminaire/services/auth.dart';
import 'package:mgtrisque_visitepreliminaire/services/crvp_printing.dart';
import 'package:mgtrisque_visitepreliminaire/services/global_provider.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  final String isNotFirstTime;
  const HomeScreen({
    super.key,
    required this.isNotFirstTime
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final _advancedDrawerController = AdvancedDrawerController();
  final List<Widget> bottomBarWidgets = [
    SyncScreen(),
    AffairesScreen(),
    VisiteScreen(),
  ];
  final List<String> bottomBarNames = [
    'Synchronisation',
    'Affaires',
    'Visite préliminaire',
  ];
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
          title: Text(
              '${Provider.of<GlobalProvider>(context, listen: true).screenTitle}'),
          titleSpacing: 0.0,
          backgroundColor: Provider.of<GlobalProvider>(context, listen: true).currentIndex == 1
              ? Colors.purple.withOpacity(0.7)
              : (Provider.of<GlobalProvider>(context, listen: true).currentIndex == 0
                  ? Colors.blueAccent.withOpacity(0.7)
                  : Colors.redAccent.withOpacity(0.7)),
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
            if (Provider.of<GlobalProvider>(context, listen: true).currentIndex == 1)
              Container(
                width: MediaQuery.of(context).size.width * 1 / 2,
                child: AnimatedSearchBar(
                    label: "Trouver un(e) affaire/site",
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
                      Provider.of<Affaires>(context, listen: false)
                          .setfoundAffaires = value;
                    },
                    onFieldSubmitted: (value) {
                      Provider.of<Affaires>(context, listen: false)
                          .setfoundAffaires = value;
                    }),
              ),
            if (Provider.of<GlobalProvider>(context, listen: true).currentIndex == 2)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0
                  ),
                  child: Text(
                    '${Provider.of<GlobalProvider>(context, listen: true).selectedAffaire}'
                        ' / '
                        '${Provider.of<GlobalProvider>(context, listen: true).selectedSite}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (Provider.of<GlobalProvider>(context, listen: true).currentIndex == 2 && Provider.of<GlobalProvider>(context, listen: true).selectedAffaire != '' && Provider.of<GlobalProvider>(context, listen: true).selectedSite != '' && Provider.of<GlobalProvider>(context, listen: true).validCRVPIng == '1')
              IconButton(
                onPressed: () => printPDF(context),
                icon: Icon(Icons.picture_as_pdf_rounded),
              ),
          ],
        ),
        bottomNavigationBar: SalomonBottomBar(
          margin: EdgeInsets.symmetric(horizontal: 30.0),
          currentIndex:
              Provider.of<GlobalProvider>(context, listen: true).currentIndex,
          onTap: (i) {
            Provider.of<GlobalProvider>(context, listen: false)
                .setCurrentIndex = i;
            Provider.of<GlobalProvider>(context, listen: false).setScreenTitle =
                bottomBarNames[i];
          },
          items: [
            /// Synchronisation
            SalomonBottomBarItem(
              icon: Image.asset(
                'assets/images/syncing.png',
              ),
              title: Text("Sync"),
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
          index:
              Provider.of<GlobalProvider>(context, listen: true).currentIndex,
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
                  padding: const EdgeInsets.only(
                    top: 5.0
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/user_avatar.png',
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
                          '${Provider.of<Auth>(context, listen: false).user?.nom} ${Provider.of<Auth>(context, listen: false).user?.prenom}',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )),
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
                    Provider.of<GlobalProvider>(context, listen: false).setSelectedAffaire = '';
                    await Provider.of<GlobalProvider>(context, listen: false).setSelectedSite('');
                    Provider.of<GlobalProvider>(context, listen: false).setCurrentIndex = 1;
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginScreen(isNotFirstTime: widget.isNotFirstTime)));
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
    _advancedDrawerController.showDrawer();
  }

  @override
  bool get wantKeepAlive => true;
}
