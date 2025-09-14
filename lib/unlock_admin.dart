import 'package:digital_register/admin_main_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class UnlockAdmin extends StatefulWidget {
  const UnlockAdmin({super.key});

  @override
  State<UnlockAdmin> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<UnlockAdmin> {
  final TextEditingController _pinController = TextEditingController();
  final Box taskBox = Hive.box('tasks');
  @override
  Widget build(BuildContext context) {
    final task = taskBox.getAt(taskBox.length-1);

    final String pin = task?['Pin'] ?? '';


    return Scaffold(

      body: Container(decoration: BoxDecoration(color: Colors.black),child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Enter passcode to unlock',style: GoogleFonts.poppins(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white)),
          SizedBox(height: 10,),  
          PinCodeTextField(appContext: context, length: 4,obscureText: true,obscuringCharacter: '.',  
            keyboardType: TextInputType.number,controller: _pinController, pinTheme: PinTheme(
    shape: PinCodeFieldShape.underline, // this causes "_"
    // 👇 change to none by using transparent colors
   
    fieldHeight: 40,
    fieldWidth: 30,             // 👈 decrease width = less spacing
  ), textStyle: TextStyle(
    fontSize: 24,
    letterSpacing: 2,           // 👈 tighter control of spacing
  ), backgroundColor: Colors.transparent,),
            SizedBox(height: 30,),
            ElevatedButton.icon(icon: Icon(Icons.arrow_right),onPressed: (){
                if(pin.isNotEmpty && _pinController.text==pin){
                     Navigator.push(context, MaterialPageRoute(builder: (context)=>
                    AdminMain()
                     ));
                }
                else{
                    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Incorrect PIN!'),
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 2),
      ),
    );
                }
            }, label: Text('Proceed'))
        ],
      )),
    );
  }
}