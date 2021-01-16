import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wybe/screens/multi3_screen.dart';

User user;

class Auth_Screen extends StatefulWidget {

  @override
  _Auth_Screen createState() => _Auth_Screen();
}

class _Auth_Screen extends State<Auth_Screen> {

  // контроллеры для текстовых полей
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();


  @override
  void initState() {
    super.initState();
    auth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            child: TextFormField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(labelText: 'Phone number (+x xxx-xxx-xxxx)'),
            ),
          ),
          Container(
            child:
                RaisedButton(child: Text("Получить код"),
                    onPressed: () async => {

                      // для быстрых тестов:
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Multi3()),
                        )

                      // для тестов с смс:

                      //auth_final(_phoneNumberController.text)
                      //_phoneNumberController.text = await _autoFill.hint
                    },
          ),),

          Container(
            child: TextFormField(
              controller: _smsController,
              decoration: const InputDecoration(labelText: 'your sms'),
            ),
          ),
          Container(
            child:
            RaisedButton(child: Text("Войти"),
              onPressed: () async => {
                signInWithPhoneNumber()
                //_phoneNumberController.text = await _autoFill.hint
              },
            ),)

        ],
      ),
    );
  }


  void auth() async {
    await Firebase.initializeApp();
  }

  String _verificationId;

  void showSnackbar(String message) {
    try{
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(message),
      ));
    }catch(EX){}
  }

  // отправка кода
  void auth_final(String string) async{

    // init firebase
    await Firebase.initializeApp();
    FirebaseAuth auth = FirebaseAuth.instance;


    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {

      await auth.signInWithCredential(phoneAuthCredential);
      print("Phone number automatically verified and user signed in: ${auth.currentUser.uid}");

    };
    PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      print(authException);
    };

    PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      print("CHECK CODE");
      showSnackbar("Код отправлен");
      _verificationId = verificationId;
    };

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      print("verification code: " + verificationId);
      _verificationId = verificationId;
    };

    // тут основа отправки кода, думаю понятно
    try {
      await auth.verifyPhoneNumber(
          phoneNumber: string,
          timeout: const Duration(seconds: 5),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      showSnackbar("Failed to Verify Phone Number: ${e}");
    }

  }


  // ввод смс кода и регистрация.
  void signInWithPhoneNumber() async {

    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _smsController.text,
      );

      // вот тут получаем юзера и дальше его сохраняем. у нас есть айдишник
      user = (await auth.signInWithCredential(credential)).user;

      print("Successfully signed in UID: ${user.uid}");
      showSnackbar("Успешно, ваш ID: ${user.uid}");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Multi3()),
      );
    } catch (e) {
      showSnackbar("Ошибка" + e.toString());

      print("Failed to sign in: " + e.toString());
    }
  }

}