import 'package:flutter/material.dart';
import 'package:mgtrisque_visitepreliminaire/screens/login_screen.dart';

class GetStarted extends StatelessWidget {
  GetStarted({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffe4e9f9),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 1 / 2,
                      height: 50.0,
                      margin: EdgeInsets.only(
                        top: 40.0,
                        bottom: 10.0,
                        left: 30.0,
                      ),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: const AssetImage('assets/images/mgt_logo.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  width: MediaQuery.of(context).size.width * 9 / 10,
                  height: MediaQuery.of(context).size.width * 9 / 10,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage('assets/images/engineers.png'),
                      fit: BoxFit.fill,
                      colorFilter: new ColorFilter.mode(
                        Colors.black,
                        BlendMode.dstIn,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/visite_preliminaire.png',
                      scale: 1.2,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      child: Text(
                        'Visite Préliminaire',
                        style: TextStyle(
                          fontFamily: 'Malgun Gothic',
                          fontSize: 25,
                          color: const Color(0xff707070),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 5.0,
                    vertical: 5.0,
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 2 / 3,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(
                              left: 15.0, right: 15.0, bottom: 5.0),
                          decoration: BoxDecoration(
                              color: Color(0xff3D73AA),
                              borderRadius: BorderRadius.circular(17.0)),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                            },
                            child: Text(
                              'Commencer',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 25,
                                color: const Color(0xffFFFFFF),
                              ),
                              textAlign: TextAlign.center,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
