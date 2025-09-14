import 'package:digital_register/admin.dart';
import 'package:digital_register/admin_main_ui.dart';
import 'package:digital_register/adminui_provider.dart';
import 'package:digital_register/language_provider.dart';
import 'package:digital_register/residentinfo.dart';
import 'package:digital_register/residentmainui.dart';
import 'package:digital_register/status_provider.dart';
import 'package:digital_register/unlock_admin.dart';
import 'package:digital_register/user_model.dart';
import 'package:digital_register/user_repository.dart';
import 'package:digital_register/visitor_entry_page.dart';
import 'package:digital_register/visitor_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';




void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('tasks');
  await Hive.openBox('residenttasks');
  await Hive.openBox('status');
  await Firebase.initializeApp();
  Get.put(UserRepository());
  final statusProvider = StatusProvider();
  statusProvider.loadStatus();
  statusProvider.loadReason();
  
  
  runApp(MultiProvider(providers:[ChangeNotifierProvider(create: (_) => LanguageProvider()),ChangeNotifierProvider(create: (_)=>AdminuiProvider()),ChangeNotifierProvider.value(value:statusProvider)],child:const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().currentLang;


    return MaterialApp(
      locale: Locale(lang),
      supportedLocales: [
        Locale('en'),
        Locale('hi')
      ],
     localizationsDelegates:[  GlobalMaterialLocalizations.delegate,   // For Material widgets
    GlobalWidgetsLocalizations.delegate,    // For basic widgets
    GlobalCupertinoLocalizations.delegate,  // For Cupertino widgets
  
     ],  
                // For your own app strings,
  theme: ThemeData.light(), // Optional: your light theme
  darkTheme: ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[900],
      labelStyle: TextStyle(color: Colors.white70),
      prefixIconColor: Colors.white70,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme.apply(bodyColor: Colors.white),
    ),
  ),
  themeMode: ThemeMode.dark, // Force dark mode
  home: const MyHomePage(title: '',),
);

  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final Box taskBox = Hive.box('tasks');
  final Box taskBoxresident = Hive.box('residenttasks');
  final Box status = Hive.box('status');
  

  @override
  void initState() {
    super.initState();
    _checkData();
  }


  void _checkData() async{
     if (taskBoxresident.isNotEmpty) {
  final task = taskBoxresident.getAt(taskBoxresident.length - 1);
  

  final String nameCat = task?['name'] ?? '';
  final String roomCat = task?['roomno'] ?? '';
  final String phoneno = task?['phoneno'] ?? '';

  

  


  


  final user = UserModel(Name: nameCat, Roomno: roomCat, PhoneNo: phoneno);
  String docId = await UserRepository.instance.createUser(user);

  
  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>ResidentmainuiPage(docId: docId,phoneNo: phoneno)));

  return;
  
  
} 

  
  

  // Check visitor tasks
    for (int i = 0; i < taskBox.length; i++) {
      if (taskBox.getAt(i) != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UnlockAdmin()),
          );
        });
        return;
      }
    }
  }
  

  @override
  Widget build(BuildContext context) {

    

    
 


 

 
    

  
   
   
    
    return Scaffold(
      appBar: AppBar( 
  backgroundColor: Colors.black,
  title: Text(context.watch<LanguageProvider>().getText('welcome'),style: GoogleFonts.poppins(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),),

  actions: [ FloatingActionButton(onPressed: (){
    final lang = context.read<LanguageProvider>().currentLang;
    final newlang = lang == 'en'?'hi':'en';
    context.read<LanguageProvider>().changeLanguage(newlang);
    
  },child: Text(context.watch<LanguageProvider>().currentLang == 'en' ? 'हि' : 'en'),),
    InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alert!'),
              content: Text('You must select preference before other details!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
      child: CircleAvatar(
        backgroundImage: AssetImage('assets/images/ukperson.jpg'),
      ),
    ),
    SizedBox(width: 20),
  ],
)
,
      body: Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      
      
      // 🔳 Black Container box
      Expanded(child:Container(
        decoration: BoxDecoration(color: Colors.black),
        padding: EdgeInsets.all(20), // Optional padding inside the container
        child: Center(
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,
           
            children: [
              // 📝 Heading Text\
              SizedBox(height: 180,),
              Text(
                context.watch<LanguageProvider>().getText('preference'),
                style: GoogleFonts.poppins(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height*0.1),

              // 🔐 Admin Button
              
              Center(child:ElevatedButton.icon(
                onPressed: () {Navigator.push(context,MaterialPageRoute(builder:(context)=> AdminPage()));},
                icon: Icon(Icons.security,color: Colors.white,size:30),
                label: Text(context.watch<LanguageProvider>().getText('admin'),style: GoogleFonts.poppins(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.white),),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black)
                
               
              )),

              SizedBox(height: 10),

              // 👤 Resident Button
              ElevatedButton.icon(
                onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context)=>ResidentInfoPage()));},
                icon: Icon(Icons.person,color: Colors.white,size: 30,),
                label: Text(context.watch<LanguageProvider>().getText('resident'),style: GoogleFonts.poppins(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.white),),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                
              ),
            ],
          )),
        ),
      ),
    ],
  ),
)
,
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  
  }
}
