import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:speech2face_app/modules/showing_audio_screen/showing_audio_screen.dart';
import 'package:speech2face_app/shared/blocs/app_cubit/app_cubit.dart';


import '../../shared/style/colors.dart';
import '../record_audio_screen/recording_audio_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {
        if(state is GetFileSuccessfully){
          Navigator.push(context, MaterialPageRoute(builder: (_)=> const ShowingSelectedAudioScreen(isFromPicker: true,)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0.0,
            title: Text(
              'Speech2Face',
              style: GoogleFonts.lato(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w800
              ),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 20.0
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/imgs/LOGO.png",
                ),
                /*const SizedBox(
              height: 20.0,
            ),
            Text(
              'Welcome to Speech2Face application',
              style: GoogleFonts.lato(
                  fontSize: 18.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w800
              ),
            ),*/
                const SizedBox(
                  height: 20.0,
                ),
                SizedBox(
                  height: 80,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            AppCubit.get(context).getFileFromFolders();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              color: btnColor,
                            ),
                            child: Column(
                              children: [
                                const Spacer(),
                                const Icon(
                                  Icons.drive_folder_upload,
                                  color: Colors.white,
                                ),
                                const Spacer(),
                                Text(
                                  'Upload from file',
                                  style: GoogleFonts.lato(
                                      color: Colors.white,
                                      fontSize: 16.0
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RecordingAudioScreen()),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              color: btnColor,
                            ),
                            child: Column(
                              children: [
                                const Spacer(),
                                const Icon(
                                  Icons.multitrack_audio,
                                  color: Colors.white,
                                ),
                                const Spacer(),
                                Text(
                                  'Record an audio',
                                  style: GoogleFonts.lato(
                                      color: Colors.white,
                                      fontSize: 16.0
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}
