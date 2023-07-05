import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech2face_app/modules/home_screen/home_screen.dart';
import 'package:speech2face_app/shared/style/colors.dart';

class ResultScreen extends StatelessWidget {
  final String url;
  const ResultScreen({Key? key ,required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          'Prediction Result',
          style: GoogleFonts.lato(
            fontSize: 24.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: bgColor,
      body: Column(
        children: [
          const Spacer(),
          Center(
            child: SizedBox(
              width: 224,
              height: 224,
              child: Image.network(
                url,
                width: 224,
                height: 224,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_)=>const HomeScreen()),
                      (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.red.shade900,
              //padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              textStyle: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text(
              'Back Home',
            ),
          ),
          const SizedBox(
            height: 50.0,
          ),
        ],
      ),
    );
  }
}
