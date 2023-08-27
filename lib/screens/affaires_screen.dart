import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
    return SingleChildScrollView(
      child: Container(
        width: size.width,
        height: size.height-135.0,
        color: Colors.purple.withOpacity(0.1),
        child: Column(
          children: [
          Expanded(
              child: Consumer<Affaires>(
                builder: (BuildContext context, affaires, Widget? child) {
                  return affaires.foundAffaires.length == 0
                      ? Container(
                        width: size.width,
                        height: size.height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/animations/nodata-animation.json',
                            ),
                            const Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 10.0
                              ),
                              child: const Text(
                                'Aucune affaire trouvée !',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 28.0,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 10.0
                              ),
                              child: const Text(
                                'Aucune affaire n\'a été assignée à cet utilisateur',
                                style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 18.0
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.custom(
                        childrenDelegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Column(
                              children: [
                                Container(
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
                                              Provider.of<GlobalProvider>(context, listen: false).selectedAffaire == affaires.affaires[index%affaires.affaires.length].Code_Affaire
                                                  ? Provider.of<GlobalProvider>(context, listen: false).setSelectedAffaire = ''
                                                  : Provider.of<GlobalProvider>(context, listen: false).setSelectedAffaire = affaires.affaires[index%affaires.affaires.length].Code_Affaire;

                                              Provider.of<Affaires>(context, listen: false).setfoundSites = affaires.affaires[index%affaires.affaires.length].Code_Affaire;
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.all(2.0),
                                              child: Icon(
                                                  Provider.of<GlobalProvider>(context, listen: true).selectedAffaire == affaires.affaires[index%affaires.affaires.length].Code_Affaire
                                                      ? Icons.keyboard_double_arrow_down
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
                                            '${affaires.affaires[index%affaires.affaires.length].Code_Affaire}',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15.0
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              affaires.affaires[index%affaires.affaires.length].NbrSite > 1 ? 'Multi' : 'Mono',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.0
                                              ),
                                            ),
                                            decoration: BoxDecoration(
                                                color: affaires.affaires[index%affaires.affaires.length].NbrSite > 1 ? Colors.amber : Colors.cyan,
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
                                          overflow: TextOverflow.clip,
                                          text: TextSpan(
                                              text: '${affaires.affaires[index%affaires.affaires.length].IntituleAffaire}',
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
                                          width: Provider.of<GlobalProvider>(context, listen: true).selectedAffaire == affaires.affaires[index%affaires.affaires.length].Code_Affaire
                                              ? 2.0
                                              : 0.0,
                                          color: Colors.purple.withOpacity(0.6)
                                      )
                                  ),
                                ),
                                if(Provider.of<GlobalProvider>(context, listen: true).selectedAffaire == affaires.affaires[index%affaires.affaires.length].Code_Affaire)
                                  ListView.custom(
                                    childrenDelegate: SliverChildBuilderDelegate(
                                      (innerContext, innerIndex) {
                                        return Container(
                                          height: 45.0,
                                          width: size.width,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 40.0,
                                              vertical: 2.0
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
                                                      color: Colors.black.withOpacity(0.6),
                                                    ),
                                                    borderRadius: BorderRadius.circular(8.0),
                                                  ),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      (
                                                          Provider.of<GlobalProvider>(context, listen: false).selectedSite == Provider.of<Affaires>(context, listen: false).foundSites[innerIndex].Code_site
                                                              &&
                                                              Provider.of<GlobalProvider>(context, listen: false).selectedAffaire == Provider.of<Affaires>(context, listen: false).foundAffaires[index].Code_Affaire
                                                      )
                                                          ? Provider.of<GlobalProvider>(context, listen: false).setSelectedSite('')
                                                          : Provider.of<GlobalProvider>(context, listen: false).setSelectedSite(Provider.of<Affaires>(context, listen: false).foundSites[innerIndex].Code_site);

                                                      await Provider.of<GlobalProvider>(context, listen: false).setVisiteExistes();
                                                    },
                                                    child: Padding(
                                                      padding: EdgeInsets.all(2.0),
                                                      child: Icon(
                                                          (
                                                              Provider.of<GlobalProvider>(context, listen: false).selectedSite == Provider.of<Affaires>(context, listen: false).foundSites[innerIndex].Code_site
                                                                  &&
                                                                  Provider.of<GlobalProvider>(context, listen: false).selectedAffaire == Provider.of<Affaires>(context, listen: false).foundAffaires[index].Code_Affaire
                                                          )
                                                              ? Icons.keyboard_double_arrow_right_sharp
                                                              : Icons.check,
                                                          size: 20.0,
                                                          color: Colors.black.withOpacity(0.6)
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10.0),
                                              Text(
                                                '${Provider.of<Affaires>(context, listen: false).foundSites[innerIndex].Code_site}',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15.0
                                                ),
                                              ),
                                              SizedBox(width: 10.0),
                                              Expanded(
                                                child: RichText(
                                                  text: TextSpan(
                                                      text: '${Provider.of<Affaires>(context, listen: false).foundSites[innerIndex].adress_proj}',
                                                      style: TextStyle(
                                                          color: Colors.black
                                                      )
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          decoration: BoxDecoration(
                                              color: Colors.purple.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(8.0),
                                              border: Border.all(
                                                width: 1.5,
                                                color: Colors.purple.withOpacity(0.6),
                                              )
                                          ),
                                        );
                                      },
                                      childCount: Provider.of<Affaires>(context, listen: true).foundSites.length,
                                    ),
                                    shrinkWrap: true,
                                    physics: ScrollPhysics(),
                                  ),
                              ],
                            );
                          },
                          childCount: affaires.foundAffaires.length,
                        )
                      );
                },
              )
          ),
          ],
        ),
      ),
    );
  }
}
