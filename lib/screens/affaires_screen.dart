import 'package:flutter/material.dart';
import 'package:mgtrisque_visitepreliminaire/services/affaires.dart';
import 'package:provider/provider.dart';

class AffairesScreen extends StatefulWidget {
  const AffairesScreen({Key? key}) : super(key: key);


  @override
  State<AffairesScreen> createState() => _AffairesScreenState();
}

class _AffairesScreenState extends State<AffairesScreen> {

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    late List affaires = Provider.of<Affaires>(context, listen: true).foundAffaires;
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
        height: size.height-135.0,
        child: Column(
          children: [
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
                        child: Row(
                          children: [
                            Material(
                              type: MaterialType.transparency,
                              child: Ink(
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1.5),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    // todo: select affaire
                                    print('test');
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(
                                      Icons.check,
                                      size: 25.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.0),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${affaires[index%affaires.length].Code_Affaire}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15.0
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    affaires[index%affaires.length].NbrSite > 1 ? 'Multi' : 'Mono',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.0
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(8.0)
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 5.0,
                                    vertical: 1.0
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 10.0),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: '${affaires[index%affaires.length].IntituleAffaire}',
                                  style: TextStyle(
                                    color: Colors.black
                                  )
                                ),
                              ),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.0)
                        ),
                      );
                    },
                    childCount: affaires.length*5,
                  )
              )
          ),
          ],
        ),
      ),
    );
  }
}
