import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech2face_app/modules/showing_audio_screen/showing_audio_screen.dart';
import 'package:speech2face_app/shared/blocs/app_cubit/app_cubit.dart';

import 'dart:io';

import 'package:speech2face_app/shared/style/colors.dart';
import 'package:speech2face_app/shared/style/toast.dart';

class RecordingAudioScreen extends StatefulWidget {
  const RecordingAudioScreen({Key? key}) : super(key: key);

  @override
  State<RecordingAudioScreen> createState() => _RecordingAudioScreenState();
}

class _RecordingAudioScreenState extends State<RecordingAudioScreen> {
  late final RecorderController recorderController = RecorderController()
    ..androidEncoder = AndroidEncoder.aac
    ..androidOutputFormat = AndroidOutputFormat.mpeg4
    ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
    ..sampleRate = 16000;
  String? path;



  late Directory directory;



  void getDirectory() async {
    directory = await getApplicationDocumentsDirectory();
    path = "${directory.path}/speech2face_recorder.mp3";
  }

  @override
  void initState() {
    super.initState();
    getDirectory();
  }

  void _startAndStopRecording() async {
    if (!recorderController.isRecording) {
      await recorderController.record(path: path!);
      AppCubit.get(context).updateCounter();
    } else {
      if(AppCubit.get(context).noSeconds < 6){
       ToastConfig.showToast(
           msg: 'You must record at least 6 seconds',
           toastStates: ToastStates.Error
       );
      }
      else {
        await recorderController.stop();
        AppCubit.get(context).getRecorder();
      }
    }
    recorderController.refresh();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {
        if (state is GetFileSuccessfully) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (_) => const ShowingSelectedAudioScreen(isFromPicker:false)),
            (route) => false,
          );
          AppCubit.get(context).noSeconds = 0;
        }
        if(state is UpdateCounter){
          AppCubit.get(context).updateCounter();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 10.0,
              ),
              child: Column(
                children: [
                  Text(
                    '${AppCubit.get(context).noSeconds}s',
                    style:
                        GoogleFonts.lato(fontSize: 60.0, color: Colors.white),
                  ),
                  AudioWaveforms(
                    enableGesture: false,
                    size: Size(MediaQuery.of(context).size.width,
                        MediaQuery.of(context).size.height / 1.5),
                    recorderController: recorderController,
                    waveStyle: const WaveStyle(
                      waveColor: Colors.white,
                      extendWaveform: true,
                      showMiddleLine: false,
                      showBottom: true,
                      middleLineThickness: 2.0,
                      middleLineColor: Colors.white,
                      durationLinesColor: Colors.grey,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.only(left: 18),
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _startAndStopRecording,
                        icon: CircleAvatar(
                          backgroundColor: Colors.red.shade900,
                          radius: 64.0,
                          child: Center(
                            child: Icon(
                              recorderController.isRecording
                                  ? Icons.check
                                  : Icons.fiber_manual_record_sharp,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
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
    recorderController.dispose();
    AppCubit.get(context).noSeconds = 0;
  }
}
