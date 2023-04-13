import 'package:flutter/material.dart';
import 'package:mgtrisque_visitepreliminaire/services/affaires.dart';
import 'package:mgtrisque_visitepreliminaire/services/global_provider.dart';
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
    return SingleChildScrollView(
      child: Container(
        width: size.width,
        height: size.height-135.0,
        color: Colors.purple.withOpacity(0.1),
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
                                  border: Border.all(
                                    width: 1.5,
                                    color: Colors.purple.withOpacity(0.6),
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    // todo: select affaire
                                    print('test : ${affaires[index%affaires.length].Code_Affaire}');
                                    Provider.of<GlobalProvider>(context, listen: false).selectedAffaire == affaires[index%affaires.length].Code_Affaire
                                      ? Provider.of<GlobalProvider>(context, listen: false).setSelectedAffaire = ''
                                      : Provider.of<GlobalProvider>(context, listen: false).setSelectedAffaire = affaires[index%affaires.length].Code_Affaire;

                                    if(Provider.of<GlobalProvider>(context, listen: false).selectedAffaire == affaires[index%affaires.length].Code_Affaire) {
                                      Provider.of<GlobalProvider>(context, listen: false).setCurrentIndex = 2;
                                      Provider.of<GlobalProvider>(context, listen: false).setScreenTitle = 'Visite Préliminaire';
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(
                                      Provider.of<GlobalProvider>(context, listen: true).selectedAffaire == affaires[index%affaires.length].Code_Affaire
                                      ? Icons.double_arrow
                                      : Icons.check,
                                      size: 25.0,
                                        color: Colors.purple.withOpacity(0.6)
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
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            width: Provider.of<GlobalProvider>(context, listen: true).selectedAffaire == affaires[index%affaires.length].Code_Affaire
                              ? 2.0
                              : 0.0,
                            color: Colors.purple.withOpacity(0.6)
                          )
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
