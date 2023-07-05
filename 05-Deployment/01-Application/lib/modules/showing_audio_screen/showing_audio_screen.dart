import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech2face_app/modules/result_screen/result_screen.dart';
import 'package:speech2face_app/shared/blocs/app_cubit/app_cubit.dart';
import 'package:speech2face_app/shared/style/colors.dart';

import '../home_screen/home_screen.dart';

class ShowingSelectedAudioScreen extends StatefulWidget {
  final bool isFromPicker;
  const ShowingSelectedAudioScreen({Key? key , required this.isFromPicker}) : super(key: key);

  @override
  State<ShowingSelectedAudioScreen> createState() =>
      _ShowingSelectedAudioScreenState();
}

class _ShowingSelectedAudioScreenState
    extends State<ShowingSelectedAudioScreen> {
      int gender = 0;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {
        if (state is UploadAudioSuccessfully) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => ResultScreen(url: state.url),
              ),
              (route) => false);
        }
      },
      builder: (context, state) {
        var cubit = AppCubit.get(context);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0.0,
            centerTitle:  true,
            title: state is UploadAudioLoading? const SizedBox(): IconButton(
                                  onPressed: () {
                                    cubit.playAndPauseControl();
                                  },
                                  icon: Icon(
                                    cubit.playerController.playerState.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                ),
          ),
          backgroundColor: bgColor,
          body: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: state is UploadAudioLoading ? Center(
                child: CircularProgressIndicator(
                  color: Colors.red.shade900,
                ),
              ):Stack(
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width:MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: AudioFileWaveforms(
                              size: Size(MediaQuery.of(context).size.width,
                                  MediaQuery.of(context).size.height * 0.4,
                                  ),
                              playerController: cubit.playerController,
                              playerWaveStyle: PlayerWaveStyle(
                                scaleFactor: 120,
                                seekLineColor: Colors.red.shade900,
                                seekLineThickness: 1.0,
                                fixedWaveColor: Colors.white30,
                                liveWaveColor: Colors.white,
                                waveCap: StrokeCap.butt,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding: const EdgeInsets.only(left: 18),
                              margin: const EdgeInsets.symmetric(horizontal: 15),
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          SizedBox(
                            height: 100.0,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              children: [
                                  Expanded(
                                    child: RadioListTile(
                                                  activeColor: Colors.red.shade900,
                                                  title: const Text(
                                                    "Male",
                                                    style: TextStyle(
                                                      color: Colors.white
                                                    ),
                                                  ),
                                                  value: 0,
                                                  groupValue: gender,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      gender = (value) as int;
                                                    });
                                                  },
                                                ),
                                  ),
                                              Expanded(
                                                child: RadioListTile(
                                                  activeColor: Colors.red.shade900,
                                                  title: const Text(
                                                    'Female',
                                                    style: TextStyle(
                                                      color: Colors.white
                                                    ),
                                                  ),
                                                  value: 1,
                                                  groupValue: gender,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      gender = value as int;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                        
                            ),
                          ),
                        
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Row(
                      children: [
                        Expanded(
                          child :ElevatedButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const HomeScreen()),
                                (route) => false,
                              );
                              cubit.playerController.dispose();
                              cubit.noSeconds = 0;
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade900,
                              textStyle: GoogleFonts.lato(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text(
                              'Back Home',
                            ),
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                                
                                child: ElevatedButton(
                                  onPressed: () {
                                    AppCubit.get(context).playerController.dispose();
                                    cubit.uploadAudio(
                                      isFromPicker: widget.isFromPicker,
                                      gender: gender == 0 ? "male" :"female"
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
                                    'Send for predictions',
                                  ),
                                ),
                              ),
                          ],
                          ),
                          ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    AppCubit.get(context).playerController.dispose();
  }
}
