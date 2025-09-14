import 'dart:io';

import 'package:digital_register/admin_main_ui.dart';
import 'package:digital_register/language_provider.dart';
import 'package:digital_register/visitor_entry_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});



  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final Box taskBox = Hive.box('tasks');
  bool otpSent = false;
  bool otpverified = false;
  String vid = "";
   double progress=0;
   late AnimationController controller;
   late Animation loadinganimation;

   @override
void initState() {
  super.initState();
  controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  // Start with progress = 0
  loadinganimation = AlwaysStoppedAnimation(0.0);
}


  void _updateProgress(double newValue) {
  setState(() {
    final oldProgress = progress;
    progress = (progress + newValue).clamp(0.0, 1.0);

    loadinganimation = Tween<double>(begin: oldProgress, end: progress).animate(
      CurvedAnimation(parent: controller, curve: Curves.ease),
    );
    controller.forward(from: 0); // animate smoothly old → new
  });
}



  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController numController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController gateController = TextEditingController();
  final TextEditingController otpcontroller = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

Future<void> _submitForm() async {
  if (_image == null) {
    _showSnackBar("Please select a profile picture");
    return;
  } 

  if (nameController.text.trim().isEmpty) {
    _showSnackBar("Please enter your name");
    return;
  } 

  if (idController.text.trim().isEmpty) {
    _showSnackBar("Please enter Guard ID");
    return;
  } 

  if (numController.text.trim().length != 10) {
    _showSnackBar("Please enter a valid 10-digit phone number");
    return;
  }

  if (passController.text.trim().length != 4) {
    _showSnackBar("Please enter a valid 4-digit pin");
    return;
  }

  if (gateController.text.trim().isEmpty) {
    _showSnackBar("Please enter your assigned gate");
    return;
  } 

  if (otpcontroller.text.trim().isEmpty) {
    _showSnackBar("Please enter OTP");
    return;
  } 

  try {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: vid,
      smsCode: otpcontroller.text.trim(),
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    setState(() {
      otpverified = true;
    });
  } catch (e) {
    _showSnackBar("OTP verification failed: ${e.toString()}");
    return; // stop execution if OTP fails
  }

  if (!otpverified) {
    _showSnackBar("Please verify your OTP before saving");
    return;
  }

  final task = {
    'name': nameController.text.trim(),
    'Guard ID': idController.text.trim(),
    'Phone Number': numController.text.trim(),
    'Pin': passController.text.trim(), // hash if possible
    'Gate Number': gateController.text.trim(),
    'ImagePath': _image!.path,
  };

  taskBox.add(task);

  _showSnackBar("Admin details saved successfully");

  _updateProgress(1.0); // fill the progress bar fully at the end

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => AdminMain()),
  );
}



  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 2),
      ),
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
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4))
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
          prefixIcon: Icon(icon, color: theme.iconTheme.color),
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color:
                theme.inputDecorationTheme.labelStyle?.color ?? theme.hintColor,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),

        onEditingComplete: () {
    _updateProgress(0.14); // only once when user finishes editing
  }
        
        
       
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
   

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar( actions: [
        AnimatedBuilder(
          builder: (context,child) {
            return CircularProgressIndicator(value:loadinganimation.value,strokeWidth: 4,color: Colors.red,);
          }
          ,animation: loadinganimation,
          child: Text('${loadinganimation.value*100}',style: TextStyle(color: Colors.white),),
        )
      ],
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          context.watch<LanguageProvider>().getText("Admin Details"),
          style: GoogleFonts.poppins(
            color: theme.appBarTheme.foregroundColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: theme.cardColor,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : const AssetImage('assets/images/adminimg.jpg')
                            as ImageProvider,
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(
                      Icons.edit,
                      color: theme.colorScheme.onPrimary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.watch<LanguageProvider>().getText("Profile Picture"),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField(
              label: context.watch<LanguageProvider>().getText("Full Name"),
              controller: nameController,
              icon: Icons.person,
             
            ),
            _buildTextField(
              label: context.watch<LanguageProvider>().getText("Guard ID / Employee ID"),
              controller: idController,
              icon: Icons.badge,
              
            ),
            _buildTextField(
              label: context.watch<LanguageProvider>().getText("Phone Number"),
              controller: numController,
              icon: Icons.phone,
              keyboardType: TextInputType.number,
              
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              
            ),
            

           Visibility(visible: otpSent,child:TextField(controller:otpcontroller,keyboardType: TextInputType.number,decoration: InputDecoration(hintText: 'Enter OTP!'),))
           
           ,


           
            Visibility(visible: !otpSent ,child:ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor: Colors.black),onPressed: () async{
                await FirebaseAuth.instance.verifyPhoneNumber(verificationCompleted: (PhoneAuthCredential credential){}, verificationFailed: (FirebaseAuthException ex){}, codeSent: (String verificationid,int? resendtoken){
                  setState(() {
                     otpSent = true;
                  vid = verificationid;
                  });
                 
                }, codeAutoRetrievalTimeout: (String verificationid){},phoneNumber:'+918563087734',);
            }, child: Text(context.watch<LanguageProvider>().getText("send otp"),style: GoogleFonts.poppins(color:Colors.white,fontWeight: FontWeight.bold),))),
            SizedBox(height: 10,),
            _buildTextField(
              label: context.watch<LanguageProvider>().getText("pin"),
              controller: passController,
              icon: Icons.lock,
              keyboardType: TextInputType.number,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              
            ),
            _buildTextField(
              label: context.watch<LanguageProvider>().getText("gatenum"),
              controller: gateController,
              icon: Icons.door_front_door,
            
            ),
            const SizedBox(height: 30),
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
                icon: Icon(Icons.arrow_forward_sharp, color: Colors.white,),
                label: Text(
                  context.watch<LanguageProvider>().getText("save"),
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                      ),
                ),
                onPressed: _submitForm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
