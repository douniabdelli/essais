import 'package:flutter/material.dart';
import 'package:mgtrisque_visitepreliminaire/screens/home_screen.dart';
import 'package:mgtrisque_visitepreliminaire/services/auth.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _matriculeController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSigning = false;

  bool get getIsSigning => _isSigning;

  @override
  void initState() {
    _matriculeController.text = '00000';
    _passwordController.text = '1111';
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
      body: SingleChildScrollView(
        child: Container(
          child:
            Column(
              children: <Widget>[
                Row(
                  children: [
                    Container(
                      width: size.width * 1/2,
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
                                    if (value != null && value.isEmpty)
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
                                    if(value != null && value.isEmpty)
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
                            });
                            Map credentials = {
                              'matricule': _matriculeController.text,
                              'password': _passwordController.text,
                            };
                            if (_formKey.currentState!.validate()) {
                              String? token = await Provider.of<Auth>(context, listen: false).login(credentials: credentials);
                              setState(() {
                                _isSigning = false;
                              });
                              if(token != null) {
                                Navigator.pop(context);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const HomeScreen(
                                        title:
                                            'Visite Préliminaire (MgtRisque)')));
                              }
                              else {
                                setState(() {
                                  _isSigning = false;
                                });
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
              ],
            ),
        ),
      )
    );
  }
}
