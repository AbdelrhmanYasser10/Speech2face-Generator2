import 'dart:convert';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech2face_app/shared/network/remote/dio_helper.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitial());
  static AppCubit get(context) => BlocProvider.of(context);
  FilePickerResult? result;
  PlayerController playerController = PlayerController();
  int noSeconds = 0;

  void updateCounter() async {
    await Future.delayed(const Duration(seconds: 1), () {
      noSeconds++;
      emit(UpdateCounter());
    });
  }

  void getRecorder() async {
    try {
      playerController = PlayerController();
      Directory directory = await getApplicationDocumentsDirectory();
      String path = "${directory.path}/speech2face_recorder.mp3";
      playerController.preparePlayer(path: path);
      emit(GetFileSuccessfully());
    } catch (error) {
      emit(GetFileError());
    }
  }

  void getFileFromFolders() async {
    emit(GetFileLoading());
    playerController = PlayerController();
    result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['acc', 'mp3', 'wav'],
    );

    if (result != null) {
      PlatformFile file = result!.files.first;
      try {
        playerController.preparePlayer(path: file.path!);
        emit(GetFileSuccessfully());
      } catch (error) {
        emit(GetFileError());
      }
    } else {
      emit(GetFileError());
    }
    emit(GetFileError());
  }

  void playAndPauseControl() async {
    playerController.playerState == PlayerState.playing
        ? await playerController.pausePlayer()
        : await playerController.startPlayer(finishMode: FinishMode.loop);
    emit(ChangePlayingState());
  }

  void uploadAudio({
    required bool isFromPicker,
    required String gender,
  }) async {
    emit(UploadAudioLoading());
    try {
      String fileName;
      String path;
      if (isFromPicker) {
        fileName = result!.files.first.path!.split('/').last;
        path = result!.files.first.path!;
      } else {
        Directory directory = await getApplicationDocumentsDirectory();
        path = "${directory.path}/speech2face_recorder.mp3";
        fileName = "speech2face_recorder";
      }
      /*if (isFromPicker) {
        fileName = ;
        path = ;
      }
      else {
        Directory directory = await getApplicationDocumentsDirectory();
        path = "${directory.path}/speech2face_recorder.aac";
        fileName = path
            .split('/')
            .last;
      }*/

      MultipartFile file =
          await MultipartFile.fromFile(path, filename: fileName);
      FormData formData = FormData.fromMap({
        "file": file,
      });
      formData.fields.add(MapEntry("gender", gender));
      Response response =
          await DioHelper.postData(url: "/predict", data: formData);
      var jsonData = jsonDecode(response.data);
      emit(UploadAudioSuccessfully(jsonData['url']));
    } catch (error) {
      print(error.toString());
      emit(UploadAudioError());
    }
  }
}
