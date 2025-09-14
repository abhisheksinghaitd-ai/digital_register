import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_register/language_provider.dart';
import 'package:digital_register/residentmainui.dart';
import 'package:digital_register/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:digital_register/user_repository.dart';
import 'package:provider/provider.dart';


class ResidentInfoPage extends StatefulWidget
{
  const ResidentInfoPage({super.key});

  

  @override
  State<ResidentInfoPage> createState() => _ResidentInfoPageState();
}

class _ResidentInfoPageState extends State<ResidentInfoPage>{
  
  TextEditingController yournameController = TextEditingController();
   TextEditingController roomController = TextEditingController();
   TextEditingController numberController = TextEditingController();

   final Box taskBoxresident = Hive.box('residenttasks');

   void _showSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.black,
      duration: const Duration(seconds: 2),
    ),
  );
}

  void _submitForm() async {
  if (yournameController.text.trim().isEmpty) {
    _showSnackBar("Please enter your name");
    return;
  }
  if (roomController.text.trim().isEmpty) {
    _showSnackBar("Please enter room no.");
    return;
  }
  if (numberController.text.trim().isEmpty) {
    _showSnackBar("Please enter phone number");
    return;
  }
  if (numberController.text.trim().length != 10) {
    _showSnackBar("Please enter valid 10 digit phone number");
    return;
  }

  final taskResident = {
    'name':yournameController.text.trim(),
    'roomno':roomController.text.trim(),
    'phoneno':numberController.text.trim()

  };




  taskBoxresident.add(taskResident);

  final user = UserModel(
    Name: yournameController.text.trim(),
    Roomno: roomController.text.trim(),
    PhoneNo: numberController.text.trim(),
  );

  


  String docId = await UserRepository.instance.createUser(user);
  await UserRepository.instance.updateFcmToken(docId);

  // Navigate immediately after Firestore write
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ResidentmainuiPage(docId: docId,phoneNo:numberController.text.toString())),
  );
}



  @override
  Widget build(BuildContext context){
    
  final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.watch<LanguageProvider>().getText('reslogin'),style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),),
        
      body: SingleChildScrollView( 
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center  ,children: [

          SizedBox(height: 100,),

                  
                _buildTextField(label: context.watch<LanguageProvider>().getText('nameplz'),controller:yournameController,icon: Icons.edit ),
                SizedBox(height: 16,),
        _buildTextField(label: context.watch<LanguageProvider>().getText('room'), controller: roomController, icon: Icons.house),
        SizedBox(height: 16,),
        _buildTextField(label: context.watch<LanguageProvider>().getText('Phone Number'), controller: numberController, icon: Icons.phone,keyboardType:TextInputType.number,formatters: [FilteringTextInputFormatter.digitsOnly,LengthLimitingTextInputFormatter(10)] ),
        SizedBox(height: 50,),
       SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.check, color: Colors.white),
              label: Text(
                context.watch<LanguageProvider>().getText('save'),
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold,color:Colors.white),
              ),
              onPressed: _submitForm,
            ),
          )


   ] ))

      )
      );

    
  }


Widget _buildTextField({
  required String label,
  required TextEditingController controller,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? formatters,
}) {
  final theme = Theme.of(context);
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: theme.inputDecorationTheme.fillColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        color: theme.textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: theme.inputDecorationTheme.prefixIconColor),
        labelText: label,
        labelStyle: theme.inputDecorationTheme.labelStyle,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  );
}

}