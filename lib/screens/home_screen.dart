import 'package:animated_search_bar/animated_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';

import 'package:mgtrisque_visitepreliminaire/screens/login_screen.dart';
import 'package:mgtrisque_visitepreliminaire/screens/interventions_screen.dart';

import 'package:mgtrisque_visitepreliminaire/services/affaires.dart';
import 'package:mgtrisque_visitepreliminaire/services/auth.dart';
import 'package:mgtrisque_visitepreliminaire/services/pdf_generator.dart';
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

    AffairesScreen(),

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
      backdropColor: Provider.of<GlobalProvider>(context, listen: true).currentIndex == 1
          ? Colors.purple.withOpacity(0.6)
          : (Provider.of<GlobalProvider>(context, listen: true).currentIndex == 2
          ? Colors.redAccent.withOpacity(0.6)
          : Colors.blueAccent.withOpacity(0.6)
      ),
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      openScale: 1.0,
      openRatio: 0.55,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
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
                  width: 250.0,
                  height: 250.0,
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
                      bottom: 100.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          '${Provider.of<Auth>(context, listen: false).user?.nom} ${Provider.of<Auth>(context, listen: false).user?.prenom}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                          ),
                        ),
                      ],
                    )),
                ListTile(
                  onTap: () {
                    Provider.of<GlobalProvider>(context, listen: true).setCurrentIndex = 1;
                  },
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                ),
                // ListTile(
                //   onTap: () {},
                //   leading: Icon(Icons.account_circle_rounded),
                //   title: Text('Profile'),
                // ),
                // ListTile(
                //   onTap: () {},
                //   leading: Icon(Icons.settings),
                //   title: Text('Settings'),
                // ),
                ListTile(
                  onTap: () async {
                    await Provider.of<Auth>(context, listen: false).logout();
                   // Provider.of<GlobalProvider>(context, listen: false).setSelectedAffaire = '';

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
                    child: Text('CTC Algerie © ${DateTime.now().year}'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xffe4e9f9),
        appBar:AppBar(
            title: Text(
              '${Provider.of<GlobalProvider>(context, listen: true).screenTitle}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
                  titleSpacing: 0.0,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Provider.of<GlobalProvider>(context, listen: true).currentIndex == 1
                              ? Colors.purple.withOpacity(0.7)
                              : (Provider.of<GlobalProvider>(context, listen: true).currentIndex == 0
                                  ? Colors.blueAccent.withOpacity(0.7)
                                  : Colors.redAccent.withOpacity(0.7)),
                          Colors.black.withOpacity(0.5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
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
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 1 / 3,
                    child: AnimatedSearchBar(
                        label: "Trouver un(e) affaire/site",
                        controller: _searchController,
                        labelStyle: TextStyle(fontSize: 16),
                        searchStyle: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        textInputAction: TextInputAction.done,
                        searchDecoration: InputDecoration(
                          hintText: "Chercher une affaire",
                          alignLabelWithHint: true,
                          fillColor: Colors.white,
                          focusColor: Colors.white,
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                     onChanged: (value) {
  
                  Provider.of<Affaires>(context, listen: false).setfoundAffaires = value;
                },
                onFieldSubmitted: (value) {

                  Provider.of<Affaires>(context, listen: false).setfoundAffaires = value;
                },),
                                  ),
                                  SizedBox(width: 20.0,),
                                  DropdownMenu(
                  dropdownMenuEntries: ['Toutes les affaires', 'Visitées', 'Non visitées','Brouillons']
                      .map<DropdownMenuEntry<String>>((String value) {
                    return DropdownMenuEntry<String>(
                      value: value,
                      label: value,
                    );
                  }).toList(),
                  onSelected: (String? value) {
                    if (value != null) {
                      Provider.of<Affaires>(context, listen: false).setFilterAffaires = value;
                    }
                  },
                  initialSelection: 'Toutes les affaires',
                  trailingIcon: Icon(Icons.filter_list),
                ),
                ],
              ),
            if (Provider.of<GlobalProvider>(context, listen: true).currentIndex == 2)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0
                  ),

                ),
              ),

          ],
        ),
        bottomNavigationBar: SalomonBottomBar(
          margin: EdgeInsets.symmetric(horizontal: 30.0),
          currentIndex:
          Provider.of<GlobalProvider>(context, listen: true).currentIndex,
          onTap: (i) async {  if (i == 1) {
      await Provider.of<Affaires>(context, listen: false).refreshAffaires();
    }
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
                 width: 24,
    height: 24, 
              ),
              title: Text("commandes"),
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
    );
  }

  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }

  @override
  bool get wantKeepAlive => true;
}