import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_register/user_model.dart';
import 'package:digital_register/user_repository.dart';
import 'package:digital_register/visitor_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';


class VisitorEntryPage extends StatefulWidget {
  const VisitorEntryPage({super.key});

  @override
  State<VisitorEntryPage> createState() => _VisitorEntryPageState();
}

class _VisitorEntryPageState extends State<VisitorEntryPage> {
  final TextEditingController visitorController = TextEditingController();
  final TextEditingController residentController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  

  final storage = FirebaseStorage.instance;
   String? imageUrl;
   String? userId;

  Future<void> uploadProfilePic(String userId) async{
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if(pickedFile!=null){
      File file = File(pickedFile.path);

      final ref = storage.ref().child("profile-pics/$userId.jpg");

      await ref.putFile(file);

      final url = await ref.getDownloadURL();

      setState(() {
        imageUrl = url;
      });

     
    }
  }

  List<UserModel> _suggestions = [];


  void _onSearchChanged(String value) async{
    print('DEBUG: onSearchChanged called with "$value"');
    final results = await UserRepository.instance.searchUsersByNameOrRoom(value);
    setState(() {
      _suggestions = results;
    });
  }

  // Default selected string
  String selectedValue = 'Guest';

  // List of string items for the dropdown
  final List<String> options = ['Guest', 'Delivery', 'Maintenance', 'Cab'];

  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }


  

  final Box taskBox = Hive.box('tasks');

  Future<void> _submitForm() async {
    // Simple validation
    if (visitorController.text.trim().isEmpty) {
      _showSnackBar("Please enter visitor name");
      return;
    }

    if (selectedValue.isEmpty) {
      _showSnackBar("Please select visit purpose");
      return;
    }

    if (residentController.text.trim().isEmpty) {
      _showSnackBar("Please enter resident name or flat no.");
      return;
    }

    // Confirmation
    _showSnackBar("Visitor entry saved successfully");


     final visitor = VisitorModel(name: visitorController.text.trim(), roomNo: residentController.text.trim(), purpose: selectedValue,phoneNo: phoneController.text.trim(),imageUrl: imageUrl);
     await UserRepository.instance.createVisitor(visitor);
    
     
     




    // Navigate or reset form
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  VisitorEntryPage()),
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

  Widget _buildRichTextField(String label, String value, ThemeData theme) {
  return RichText(
    textAlign: TextAlign.center,
    text: TextSpan(
      children: [
        TextSpan(
          text: '$label ',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7) ?? Colors.grey[700],
          ),
        ),
        TextSpan(
          text: value.isNotEmpty ? value : 'N/A',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: theme.textTheme.bodyLarge?.color ?? Colors.black87,
          ),
        ),
      ],
    ),
  );
}

 Widget _buildTextField({
  required String label,
  required TextEditingController controller,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  ValueChanged<String>? onChanged,
}) {
  final theme = Theme.of(context);
  return Container(
    decoration: BoxDecoration(
      color: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        )
      ],
    ),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged, // ✅ This is the missing link
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        color: theme.textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: theme.iconTheme.color),
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: theme.inputDecorationTheme.labelStyle?.color ?? theme.hintColor,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

        final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  userId = user.uid; // ✅ unique ID for this user
}
  

    if (taskBox.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("My App"),
          backgroundColor: theme.appBarTheme.backgroundColor,
          foregroundColor: theme.appBarTheme.foregroundColor,
        ),
        body: Center(
          child: Text(
            "No tasks found",
            style: theme.textTheme.bodyLarge,
          ),
        ),
      );
    }

    final task = taskBox.getAt(taskBox.length - 1); // Get last  record

final String nameCat = task?['name'] ?? '';
final String idCat = task?['Guard ID'] ?? '';
final String imagePath = task?['ImagePath'] ?? '';
final String phoneCat = task?['Phone Number'] ?? '';
final String gateCat = task?['Gate Number'] ?? '';


    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Gate Entry Register',
          style: GoogleFonts.poppins(
            color: theme.appBarTheme.foregroundColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        actions: [
          InkWell(
  child: CircleAvatar(
    backgroundImage: imagePath.isNotEmpty
        ? FileImage(File(imagePath))
        : const AssetImage('assets/images/ukperson.jpg') as ImageProvider,
  ),
  onTap: () {
showGeneralDialog(
  context: context,
  barrierDismissible: true,
  barrierLabel: 'Guard Details',
  transitionDuration: Duration(milliseconds: 300),
  pageBuilder: (context, animation1, animation2) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Guard Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 2,
      ),
      body: SafeArea( 
          
          child: SingleChildScrollView( 
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: imagePath.isNotEmpty
                      ? FileImage(File(imagePath))
                      : const AssetImage('assets/images/ukperson.jpg') as ImageProvider,
                  radius: 80,
                ),
                const SizedBox(height: 40),

                Align(alignment: Alignment.center,child: _buildRichTextField('Guard Name:', nameCat, theme)),
                const SizedBox(height: 25),

                Align(alignment: Alignment.center,child:_buildRichTextField('Guard ID:', idCat, theme)),
                const SizedBox(height: 25),

                Align(alignment: Alignment.center,child:_buildRichTextField('Phone Number:', phoneCat, theme)),
                const SizedBox(height: 25),

                Align(alignment: Alignment.center,child:_buildRichTextField('Gate Number:', gateCat, theme)),
              ],
            ),
          
        ),
      ),
    );
  },
);
;
  },
)
,
          const SizedBox(width: 20),

          
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Image Picker
            GestureDetector(
            
              onTap:() => uploadProfilePic(userId!),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                 backgroundImage: imageUrl!=null?NetworkImage(imageUrl!):null,
                  child: imageUrl == null ? const Icon(Icons.person, size: 50) : null,
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
            const SizedBox(height: 10),
            Text(
              'Attach Visitor Image',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 20),

            // Visitor Name
            _buildTextField(
              label: "Visitor Name",
              controller: visitorController,
              icon: Icons.person,
            ),

            const SizedBox(height: 16),

            // Visit Purpose
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  icon: Icon(Icons.assignment, color: theme.iconTheme.color),
                  border: InputBorder.none,
                  labelText: "Select Visit Purpose",
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: theme.inputDecorationTheme.labelStyle?.color ??
                        theme.hintColor,
                  ),
                ),
                value: selectedValue,
                items: options.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: theme.textTheme.bodyLarge,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedValue = newValue!;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // Mobile Number
            _buildTextField(
              label: "Mobile Number (optional)",
              controller: phoneController,
              icon: Icons.phone,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),

            const SizedBox(height: 16),

            // Resident Name / Flat
            _buildTextField(
              label: "Resident Name / Flat No.",
              controller: residentController,
              icon: Icons.home,
              onChanged: _onSearchChanged
            ),

            const SizedBox(height: 16),

            SizedBox(height: MediaQuery.of(context).size.height * 0.3,child: 

            ListView.builder(
  shrinkWrap: true,
  itemCount: _suggestions.length,
  itemBuilder: (context, index) {
    final user = _suggestions[index];
    return ListTile(
      title: Text('Name: ${user.Name}'),
      subtitle: Text('Room No.: ${user.Roomno}\nPhone Number:${user.PhoneNo}'),
      leading: const Icon(Icons.person),
      onTap: () {
        residentController.text = "${user.Roomno}";
        phoneController.text = user.PhoneNo;
        _suggestions.clear();
        setState(() {});
      },
    );
  },
),

            ),

            

            const SizedBox(height: 16),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.check, color: theme.colorScheme.onPrimary),
                label: Text(
                  "Submit Entry",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
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
