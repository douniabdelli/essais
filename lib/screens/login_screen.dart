import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgtrisque_visitepreliminaire/screens/interventions_screen.dart';
import 'package:mgtrisque_visitepreliminaire/services/auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  final String isNotFirstTime;
  const LoginScreen({Key? key, required this.isNotFirstTime}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _matriculeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isSigning = false;
  bool loginMatriculeError = false;
  bool loginPasswordError = false;
  final storage = const FlutterSecureStorage();

  static const Color chantierBlue = Color(0xFF1E3A8A);
  static const Color chantierAccent = Color(0xFFFBBF24);
  static const Color lightBackground = Color(0xFFF9FAFB);

  @override
  void initState() {
    _matriculeController.text = '';
    _passwordController.text = '';
    super.initState();
  }

  Future<String> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return 'v${packageInfo.version}';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: lightBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: chantierBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.construction, size: 60, color: chantierBlue),
              ),

              const SizedBox(height: 30),

              
              Text(
                'Connexion',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: chantierBlue,
                ),
              ),
             
              const SizedBox(height: 40),

              
              Container(
                width: size.width * 0.85,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: chantierBlue.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      
                      _buildInputField(
                        controller: _matriculeController,
                        label: 'Matricule',
                        hint: 'Entrez votre matricule',
                        icon: Icons.badge,
                        isError: loginMatriculeError,
                        validator: (value) {
                          if ((value != null && value.isEmpty) || loginMatriculeError) {
                            setState(() {
                              isSigning = false;
                              loginMatriculeError = true;
                            });
                            return loginMatriculeError
                                ? 'Matricule incorrect'
                                : 'Veuillez entrer un matricule';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      
                      _buildInputField(
                        controller: _passwordController,
                        label: 'Mot de passe',
                        hint: 'Entrez votre mot de passe',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        isError: loginPasswordError,
                        validator: (value) {
                          if ((value != null && value.isEmpty) || loginPasswordError) {
                            setState(() {
                              isSigning = false;
                              loginPasswordError = true;
                            });
                            return loginPasswordError
                                ? 'Mot de passe incorrect'
                                : 'Veuillez entrer un mot de passe';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      
                      Row(
                        children: [
                          Checkbox(
                            value: Provider.of<Auth>(context, listen: true).isLocally,
                            activeColor: chantierAccent,
                            checkColor: chantierBlue,
                            onChanged: (value) async {
                              setState(() => Provider.of<Auth>(context, listen: false)
                                  .setIsLocally = value ?? false);
                              await storage.write(
                                  key: 'isLocally', value: value.toString().toLowerCase());
                            },
                          ),
                          Expanded(
                            child: Text(
                              'Se connecter localement',
                              style: TextStyle(
                                fontSize: 15,
                                color: chantierBlue.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: chantierBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 6,
                          ),
                          onPressed: _onLoginPressed,
                          icon: isSigning
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.login, size: 26, color: chantierAccent),
                          label: Text(
                            isSigning ? 'Connexion en cours...' : 'Se connecter',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              
              FutureBuilder<String>(
                future: _getAppVersion(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      snapshot.data!,
                      style: TextStyle(fontSize: 14, color: chantierBlue.withOpacity(0.6)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    required IconData icon,
    bool isPassword = false,
    bool isError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: chantierBlue),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: validator,
          onChanged: (_) {
            if (isError) setState(() {});
          },
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: chantierBlue),
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: chantierBlue),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: chantierAccent, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onLoginPressed() async {
    setState(() {
      isSigning = true;
      loginMatriculeError = false;
      loginPasswordError = false;
    });

    final credentials = {
      'Matricule': _matriculeController.text,
      'password': _passwordController.text,
    };

    if (_formKey.currentState!.validate()) {
      
      
      final bool hasInternet = await _hasInternetConnection();
      final bool isLocallyChecked = Provider.of<Auth>(context, listen: false).isLocally;

      if (!hasInternet && !isLocallyChecked) {
        setState(() => isSigning = false);
        
        if (mounted) {
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Pas de connexion'),
              content: const Text(
                'Aucune connexion internet détectée. Cochez "Se connecter localement" pour pouvoir vous connecter hors ligne.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }

      final result =
          await Provider.of<Auth>(context, listen: false).login(credentials: credentials);
      final token = await storage.read(key: 'token');

      if (result == 200 || result == 201) {
        Provider.of<Auth>(context, listen: false).setIsLocally = true;
        await storage.write(key: 'isLocally', value: true.toString().toLowerCase());

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AffairesScreen(isNotFirstTime: '')),
        );
      } else {
        setState(() {
          isSigning = false;
          loginMatriculeError = result == 404;
          loginPasswordError = result == 401;
        });
        _formKey.currentState!.validate();
      }
    } else {
      setState(() => isSigning = false);
    }
  }

  
  
  Future<bool> _hasInternetConnection({Duration timeout = const Duration(seconds: 3)}) async {
    try {
      final result = await InternetAddress.lookup('example.com').timeout(timeout);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
