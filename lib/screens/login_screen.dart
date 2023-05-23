import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/screens/home_screen.dart';
import 'package:mgtrisque_visitepreliminaire/services/affaires.dart';
import 'package:mgtrisque_visitepreliminaire/services/auth.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  final String isNotFirstTime;
  LoginScreen({
    Key? key,
    required this.isNotFirstTime,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _matriculeController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSigning = false;
  bool loginMatriculeError = false;
  bool loginPasswordError = false;
  bool get getIsSigning => _isSigning;
  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    _matriculeController.text = 'A0162';
    _passwordController.text = '123456';
    _isSigning = false;
    super.initState();
  }

  @override
  void dispose() {
    _matriculeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xffe4e9f9),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: size.height,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // Row(
                  //   children: [
                  //     Container(
                  //       width: size.width * 1/2,
                  //       height: 50.0,
                  //       margin: EdgeInsets.only(
                  //           top: 40.0,
                  //           bottom: 10.0,
                  //           left: 30.0,
                  //       ),
                  //       decoration: BoxDecoration(
                  //         image: DecorationImage(
                  //           image: const AssetImage('assets/images/mgt_logo.png'),
                  //           fit: BoxFit.fill,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),


                  Column(
                    children: [
                      Container(
                        width: 300.0,
                        height: 300.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: const AssetImage('assets/images/login_image.jpg'),
                            fit: BoxFit.cover,
                            colorFilter: new ColorFilter.mode(
                                Colors.black.withOpacity(0.8), BlendMode.dstIn),
                          ),
                          borderRadius:
                          BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5.0),
                        child: Text(
                          'Connexion',
                          style: TextStyle(
                            fontFamily: 'Malgun Gothic',
                            fontSize: 40,
                            color: const Color(0xff632f5a),
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: false,
                        ),
                      ),
                    ]
                  ),
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 5.0,
                          vertical: 20.0,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              Container(
                                  width: size.width * 3/4,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.only(
                                            left: 15.0,
                                            right: 15.0,
                                            bottom: 5.0
                                        ),
                                        child: Text(
                                          'Matricule',
                                          style: TextStyle(
                                            fontFamily: 'Arial',
                                            fontSize: 20,
                                            color: const Color(0xff333030),
                                          ),
                                          textAlign: TextAlign.start,
                                          softWrap: false,
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller: _matriculeController,
                                          validator: (String? value) {
                                            if ((value != null && value.isEmpty) || loginMatriculeError)
                                              return 'Entrez un matricule correct';
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Entrez le matricule',
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(17.0),
                                              borderSide: BorderSide(
                                                  color: Color(0xffFF0000),
                                                  width: 1.0
                                              ),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(17.0),
                                              borderSide: BorderSide(
                                                  color: Color(0xffFF0000),
                                                  width: 1.0
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(17.0),
                                              borderSide: BorderSide(
                                                  color: Color(0xff707070),
                                                  width: 2.0
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(17.0),
                                              borderSide: BorderSide(
                                                color: Color(0xff707070),
                                              ),
                                            ),
                                          ),
                                          style: TextStyle(
                                            fontFamily: 'Arial',
                                            fontSize: 15,
                                            color: const Color(0x8c333030),
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 10.0),
                                  width: size.width * 3/4,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.only(
                                            left: 15.0,
                                            right: 15.0,
                                            bottom: 5.0
                                        ),
                                        child: Text(
                                          'Mot de passe',
                                          style: TextStyle(
                                            fontFamily: 'Arial',
                                            fontSize: 20,
                                            color: const Color(0xff333030),
                                          ),
                                          textAlign: TextAlign.start,
                                          softWrap: false,
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          obscureText: true,
                                          controller: _passwordController,
                                          validator: (String? value) {
                                            if((value != null && value.isEmpty) || loginPasswordError)
                                              return 'Entrez un mot de passe correct';
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Entrez le mot de passe',
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(17.0),
                                              borderSide: BorderSide(
                                                  color: Color(0xffFF0000),
                                                  width: 1.0
                                              ),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(17.0),
                                              borderSide: BorderSide(
                                                  color: Color(0xffFF0000),
                                                  width: 1.0
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(17.0),
                                              borderSide: BorderSide(
                                                  color: Color(0xff707070),
                                                  width: 2.0
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(17.0),
                                              borderSide: BorderSide(
                                                color: Color(0xff707070),
                                              ),
                                            ),
                                          ),
                                          style: TextStyle(
                                            fontFamily: 'Arial',
                                            fontSize: 15,
                                            color: const Color(0x8c333030),
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 5.0,
                          vertical: 5.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: size.width * 2/3,
                              height: 50,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(17.0),
                                  ),
                                  backgroundColor: Color(0xff3D73AA),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    _isSigning = true;
                                    loginMatriculeError = false;
                                    loginPasswordError = false;
                                  });

                                  Map credentials = {
                                    'matricule': _matriculeController.text,
                                    'password': _passwordController.text,
                                  };
                                  if (_formKey.currentState!.validate()) {
                                    late int result;
                                    result = await Provider.of<Auth>(context, listen: false).login(credentials: credentials);
                                    String? token = await storage.read(key: 'token');
                                    // todo: login result
                                    if(result == 200){
                                      await Provider.of<Affaires>(context, listen: false).getData(token: token!);
                                      Navigator.pop(context);
                                      Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => const HomeScreen(isNotFirstTime: '',)));
                                    }
                                    else {
                                      setState(() => _isSigning = false);
                                      if(result == 404)
                                        setState(() => loginMatriculeError = true);
                                      if(result == 500)
                                        setState(() => loginPasswordError = true);
                                    }
                                  }
                                },
                                icon: getIsSigning
                                    ? Container(
                                  width: 24,
                                  height: 24,
                                  padding: const EdgeInsets.all(2.0),
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                                    : const Icon(Icons.login),
                                label: Text(
                                  'Se connecter',
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
                          ],
                        ),
                      ),
                    ]
                  ),

                ],
              ),
          ),
        ),
      )
    );
  }
}
