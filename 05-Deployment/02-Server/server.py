from flask import *
import cloudinary.uploader
import torchvision.utils as vutils
import webrtcvad
from urllib import request as req
from pydub import AudioSegment
import os
import pandas as pd
import numpy as np
from tqdm import tqdm
from distutils.log import debug
from fileinput import filename
from mfcc import MFCC
from config import  NETWORKS_PARAMETERS
from config import NETWORKS_PARAMETERS_FEMALE
from network import get_network
from utils import voice2face
from vad import read_wave
import torch.nn as nn
import torch.nn.functional as F
import numpy as np


app = Flask(__name__)

API_SECRET_KEY = '759286832413946';
API_SECRET = '_I6skpHGJeC2DIAVXMkcHh6MU7s';
CLOUD_NAME = 'ddksmtpkd';


UPLOAD_FOLDER = 'uploads/audios/'

# initialization
vad_obj = webrtcvad.Vad(2)
mfc_obj = MFCC(nfilt=64, lowerf=20., upperf=7200., samprate=16000, nfft=1024, wlen=0.025)



def dealWithAudio(filenameWav , cahnnel_no,sample_w , gender):
  e_net = None
  g_net = None
  if gender == "male":
    e_net, _ = get_network('e', NETWORKS_PARAMETERS, train=False)
    g_net, _ = get_network('g', NETWORKS_PARAMETERS, train=False)
  else:
     e_net, _ = get_network('e', NETWORKS_PARAMETERS_FEMALE, train=False)
     g_net, _ = get_network('g', NETWORKS_PARAMETERS_FEMALE, train=False)
  #filename = "images/test_result.png"
  print(filenameWav)
  #audio = read_wave(filenameWav,cahnnel_no,sample_w)
  face_image = voice2face(e_net, g_net, filenameWav, vad_obj, mfc_obj,sample_w,cahnnel_no,NETWORKS_PARAMETERS['GPU'])
  vutils.save_image(face_image.detach().clamp(-1,1),
                      "images/output.png", normalize=True)
  return filename
     
     

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

@app.route('/')
def main():
    return render_template("index.html")

# VAE Route
@app.route("/predict", methods=['POST'])
def upload_file():
  app.logger.info('in upload route')
  channel_no = 0
  sample_w = 0
  AudioSegment.converter = "D:\\Computer Science ASU\\Forth- Year\\GP23' Speech2Face\\Server\\ffmpeg\\ffmpeg-master-latest-win64-gpl\\bin\\ffmpeg"
  cloudinary.config(cloud_name = CLOUD_NAME, api_key=API_SECRET_KEY,api_secret=API_SECRET)
  if request.method == 'POST':
    if 'file' not in request.files:
       return jsonify({'message':"file is required",})
    file = request.files['file']
    gender = request.form['gender']

    file.save(f"uploads/audios/{file.filename}")
       
    input_file = f"uploads/audios/{file.filename}"
    output_file = f"uploads/audios/{file.filename}"

    # read the input audio file
    audio = AudioSegment.from_file(input_file)

    # set the sample rate and number of channels
    audio = audio.set_frame_rate(16000).set_channels(1)
    channel_no = audio.channels
    sample_w = audio.sample_width

    # export the audio as a WAV file
    audio.export(output_file, format="wav")

    app.logger.info(file.filename)
    dealWithAudio(output_file,channel_no,sample_w,gender)
    upload_result = cloudinary.uploader.upload(f"images/output.png")
    app.logger.info(upload_result)
    json_result = jsonify(upload_result)
    #os.remove(file.filename)
    return json_result


app.run(host='0.0.0.0', port=80, debug=True)