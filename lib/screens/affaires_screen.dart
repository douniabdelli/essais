import 'dart:convert';

import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:mgtrisque_visitepreliminaire/models/affaire.dart';
import 'package:mgtrisque_visitepreliminaire/services/affaires.dart';
import 'package:provider/provider.dart';

class AffairesScreen extends StatefulWidget {
  const AffairesScreen({Key? key}) : super(key: key);


  @override
  State<AffairesScreen> createState() => _AffairesScreenState();
}

class _AffairesScreenState extends State<AffairesScreen> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    late List affaires = Provider.of<Affaires>(context).affaires;
    var colors = [
      Colors.red,
      Colors.blue,
      Colors.cyan,
      Colors.green,
      Colors.yellow,
    ];
    return SingleChildScrollView(
      child: Container(
        width: size.width,
        height: size.height,
        child: Column(
          children: [
            Container(
              height: 70,
              width: size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: AnimSearchBar(
                  width: size.width,
                  textController: _searchController,
                  suffixIcon: Icon(Icons.search),
                  onSuffixTap: () {
                    // todo: search
                    print('------------ Search : ${_searchController.text} ------------');
                  },
                  onSubmitted: (String value) {
                    print('+ ${value} +');
                  },
                ),
              ),
            ),
          Expanded(
              child: ListView.custom(
                  childrenDelegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Container(
                        height: 75.0,
                        width: size.width,
                        margin: EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 8.0
                        ),
                        child: Text('${affaires[index%affaires.length].Code_Affaire}'),
                        decoration: BoxDecoration(
                          color: colors[index%affaires.length],
                          borderRadius: BorderRadius.circular(8.0)
                        ),
                      );
                    },
                    childCount: affaires.length*55,

                  )
              )
          ),
          // Expanded(
          //   child: ListView.builder(
          //       itemCount: affaires.length,
          //       itemBuilder: (context, index) {
          //         return Container(
          //           height: 75.0,
          //           width: size.width,
          //           child: Text('${affaires[index].Code_Affaire}'),
          //         );
          //       }
          //     ),
          //   ),
          ],
        ),
      ),
    );
  }
}
