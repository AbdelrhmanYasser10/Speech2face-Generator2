import os
import torch
import shutil
import numpy as np
import torch.nn.functional as F

from PIL import Image
from scipy.io import wavfile

from vad import read_wave, write_wave, frame_generator, vad_collector


def rm_sil(voice_file, vad_obj):
    """
       This code snippet is basically taken from the repository
           'https://github.com/wiseman/py-webrtcvad'

       It removes the silence clips in a speech recording
    """
    audio, sample_rate = read_wave(voice_file)
    frames = frame_generator(20, audio, sample_rate)
    frames = list(frames)
    segments = vad_collector(sample_rate, 20, 50, vad_obj, frames)

    if os.path.exists('tmp/'):
        shutil.rmtree('tmp/')
    os.makedirs('tmp/')

    wave_data = []
    for i, segment in enumerate(segments):
        segment_file = 'tmp/' + str(i) + '.wav'
        write_wave(segment_file, segment, sample_rate)
        wave_data.append(wavfile.read(segment_file)[1])
    #print("Finshed writing the voice recording to the file")
    shutil.rmtree('tmp/')

    if wave_data:
        #print("The voice recording is not empty")
        vad_voice = np.concatenate(wave_data).astype('int16')
    return vad_voice


def get_fbank(voice, mfc_obj):
    # Extract log mel-spectrogra
    fbank = mfc_obj.sig2logspec(voice).astype('float32')
    #print("The shape of the log mel-spectrogram is: ", fbank.shape)
    # Mean and variance normalization of each mel-frequency
    fbank = fbank - fbank.mean(axis=0)
    fbank = fbank / (fbank.std(axis=0)+np.finfo(np.float32).eps)

    # If the duration of a voice recording is less than 10 seconds (1000 frames),
    # repeat the recording until it is longer than 10 seconds and crop.
    full_frame_number = 1000
    init_frame_number = fbank.shape[0]
    while fbank.shape[0] < full_frame_number:
        fbank = np.append(fbank, fbank[0:init_frame_number], axis=0)
        fbank = fbank[0:full_frame_number, :]
    #print("fbank returned")
    return fbank


def voice2face(e_net, g_net, voice_file, vad_obj, mfc_obj, GPU=True):
    vad_voice = rm_sil(voice_file, vad_obj)
    #print("The shape of the voice recording is: ", vad_voice.shape)
    fbank = get_fbank(vad_voice, mfc_obj)
    #print("The shape of the log mel-spectrogram is: ", fbank.shape)
    fbank = fbank.T[np.newaxis, ...]
    fbank = torch.from_numpy(fbank.astype('float32'))

    if GPU:
        fbank = fbank.cuda()
    embedding = e_net(fbank)
    embedding = F.normalize(embedding)
    face = g_net(embedding)
    return face
