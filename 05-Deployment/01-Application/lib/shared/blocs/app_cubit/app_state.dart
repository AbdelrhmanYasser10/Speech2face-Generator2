part of 'app_cubit.dart';

abstract class AppState {}

class AppInitial extends AppState {}
class GetFileLoading extends AppState {}
class GetFileSuccessfully extends AppState {}
class GetFileError extends AppState {}
class ChangePlayingState extends AppState {}
class UpdateCounter extends AppState {}

class UploadAudioLoading extends AppState{}
class UploadAudioSuccessfully extends AppState{
  final String url;
  UploadAudioSuccessfully(this.url);
}
class UploadAudioError extends AppState{}
