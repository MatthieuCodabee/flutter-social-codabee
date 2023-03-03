import 'package:flutter/material.dart';
import 'package:fluttersocial/custom_widget/my_gradient.dart';
import 'package:fluttersocial/custom_widget/my_textField.dart';
import 'package:fluttersocial/custom_widget/padding_with.dart';
import 'package:fluttersocial/model/alert_helper.dart';
import 'package:fluttersocial/model/color_theme.dart';
import 'package:fluttersocial/model/my_painter.dart';
import 'package:fluttersocial/util/firebase_handler.dart';
import 'package:fluttersocial/util/images.dart';

class AuthController extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AuthState();
}

class AuthState extends State<AuthController> {

  late PageController _pageController;
  late TextEditingController _mail;
  late TextEditingController _password;
  late TextEditingController _name;
  late TextEditingController _surname;

  @override
  void initState() {
    _pageController = PageController();
    _mail = TextEditingController();
    _password = TextEditingController();
    _name = TextEditingController();
    _surname = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mail.dispose();
    _password.dispose();
    _name.dispose();
    _surname.dispose();
    super.dispose();
  }

  hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
       child: InkWell(
         onTap: () {
           hideKeyboard();
         },
         child: Container(
           decoration: MyGradient(startColor: ColorTheme().pointer(), endColor: ColorTheme().base(), horizontal: false),
           width: MediaQuery.of(context).size.width,
           height: (MediaQuery.of(context).size.height > 700) ? MediaQuery.of(context).size.height : 700,
           child: SafeArea(
             child: Column(
               children: [
                 PaddingWith(
                     child: Image.asset(logoImage, height: MediaQuery.of(context).size.height / 5,),
                 ),

                 logOrCreateButtons(),
                 Expanded(
                   child: PageView(
                     controller: _pageController,
                     children: [
                       logCard(true),
                       logCard(false)
                     ],
                   ),
                   flex: 2,
                 ),
                 PaddingWith(
                     child:
                     TextButton(
                       onPressed: () {
                         authToFirebase();
                       },
                       child: Container(
                         height: 50,
                         width: MediaQuery.of(context).size.width * 0.7,
                         decoration: MyGradient(
                             horizontal: true,
                           radius: 25,
                           startColor: ColorTheme().accent(),
                           endColor: ColorTheme().pointer()
                         ),
                         child: Center(child: Text("C'est Parti !")),
                       )


                     )
                 )
               ],
             ),
           ),
         )
       ),
      )
    );
  }
  
  
  Widget logOrCreateButtons() {
    return Container(
      decoration: MyGradient(
          horizontal: true,
          startColor: ColorTheme().base(),
          endColor: ColorTheme().pointer(),
        radius: 25
      ),
      width: 300,
      height: 50,
      child: CustomPaint(
        painter: MyPainter(pageController: _pageController),
        child: Row(
          children: [
            btn("Se Connecter"),
            btn("Créer un compte")
          ],
        ),
      ),
    );
  }
  
  Expanded btn(String name) {
    return Expanded(
      child: TextButton(
        child: Text(name),
        onPressed: () {
          int page = (_pageController.page == 0.0) ? 1: 0;
          _pageController.animateToPage(
              page, 
              duration: Duration(milliseconds: 500), 
              curve: Curves.easeIn
          );
        },
      ),
    );
  }
  
  Widget logCard(bool userExists) {
    List<Widget> list = [];
    if (!userExists) {
      list.add(MyTextField(controller: _surname, hint: "Entrez votre prénom",));
      list.add(MyTextField(controller: _name, hint: "Entrez votre nom",));
    }
    list.add(MyTextField(controller: _mail, hint: "Adresse mail",));
    list.add(MyTextField(controller: _password, hint: "Mot de passe", obscure: true,));
    
    return PaddingWith(
        child: Center(
          child: Card(
            elevation: 7.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: list,
            ),
          ),
        )
    );

  }

  authToFirebase() {
    hideKeyboard();
    bool signIn = (_pageController.page == 0);
    String name = _name.text;
    String surname = _surname.text;
    String mail = _mail.text;
    String pwd  = _password.text;

    if ((validText(mail)) && (validText(pwd))) {
      if (signIn) {
        //Methode vers Firebase
        FirebaseHandler().signIn(mail, pwd);
      } else {
        if ((validText(name)) && (validText(surname))) {
          //Méthode vers Firebase
          FirebaseHandler().createUser(mail, pwd, name, surname);
        } else {
          //Alerte nom et prénom
          AlertHelper().error(context, "Nom ou prénom inexistant");
        }
      }
    } else {
      //Alerte utilisateur pas de mail ou mot de passe
      AlertHelper().error(context, "Mot de passe ou mail inexistant");
    }
  }

  bool validText(String string) {
    return (string != null && string != "");
  }

}

