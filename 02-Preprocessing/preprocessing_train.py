import numpy as np
import os
import torch
from PIL import Image
from torch.utils.data import Dataset
from torch.utils.data.dataloader import default_collate


def load_voice(voice_item):
    voice_data = np.load(voice_item['filepath'])
    voice_data = voice_data.T.astype('float32')
    voice_label = voice_item['label_id']
    print("Loading voice data: ", voice_data, voice_label)
    return voice_data, voice_label


def load_face(face_item):
    face_data = Image.open(face_item['filepath']).convert(
        'RGB').resize([64, 64])
    face_data = np.transpose(np.array(face_data), (2, 0, 1))
    face_data = ((face_data - 127.5) / 127.5).astype('float32')
    face_label = face_item['label_id']
    print("Loading face data: ", face_data, face_label)
    return face_data, face_label


class VoiceDataset(Dataset):
    def __init__(self, voice_list, nframe_range):
        self.voice_list = voice_list
        self.crop_nframe = nframe_range[1]

    def __getitem__(self, index):
        voice_data, voice_label = load_voice(self.voice_list[index])
        assert self.crop_nframe <= voice_data.shape[1]
        pt = np.random.randint(voice_data.shape[1] - self.crop_nframe + 1)
        voice_data = voice_data[:, pt:pt+self.crop_nframe]
        return voice_data, voice_label

    def __len__(self):
        return len(self.voice_list)


class FaceDataset(Dataset):
    def __init__(self, face_list):
        self.face_list = face_list

    def __getitem__(self, index):
        face_data, face_label = load_face(self.face_list[index])
        if np.random.random() > 0.5:
            face_data = np.flip(face_data, axis=2).copy()
        return face_data, face_label

    def __len__(self):
        return len(self.face_list)


def parse_metafile(meta_file):
    with open(meta_file, 'r') as f:
        lines = f.readlines()[1:]
    celeb_ids = {}
    for line in lines:
        ID, name, _, _, _ = line.rstrip().split('\t')
        celeb_ids[ID] = name
    return celeb_ids


def get_labels(voice_list, face_list):
    voice_names = {item['name'] for item in voice_list}
    face_names = {item['name'] for item in face_list}
    names = voice_names & face_names

    voice_list = [item for item in voice_list if item['name'] in names]
    face_list = [item for item in face_list if item['name'] in names]

    names = sorted(list(names))
    label_dict = dict(zip(names, range(len(names))))
    for item in voice_list+face_list:
        item['label_id'] = label_dict[item['name']]
    return voice_list, face_list, len(names)


def get_dataset_files(data_dir, data_ext, celeb_ids, split):
    data_list = []
    # read data directory
    for root, dirs, filenames in os.walk(data_dir):
        for filename in filenames:
            if filename.endswith(data_ext):
                filepath = os.path.join(root, filename)
                # so hacky, be careful!
                folder = filepath[len(data_dir):].split('/')[1]
                celeb_name = celeb_ids.get(folder, folder)
                if celeb_name.startswith(tuple(split)):
                    data_list.append(
                        {'filepath': filepath, 'name': celeb_name})
    return data_list


def get_dataset(data_params):
    celeb_ids = parse_metafile(data_params['meta_file'])

    voice_list = get_dataset_files(data_params['voice_dir'],
                                   data_params['voice_ext'],
                                   celeb_ids,
                                   data_params['split'])
    face_list = get_dataset_files(data_params['face_dir'],
                                  data_params['face_ext'],
                                  celeb_ids,
                                  data_params['split'])
    return get_labels(voice_list, face_list)


class Meter(object):
    # Computes and stores the average and current value
    def __init__(self, name, display, fmt=':f'):
        self.name = name
        self.display = display
        self.fmt = fmt
        self.reset()

    def reset(self):
        self.val = 0
        self.avg = 0
        self.sum = 0
        self.count = 0

    def update(self, val, n=1):
        self.val = val
        self.sum += val * n
        self.count += n
        self.avg = self.sum / self.count

    def __str__(self):
        fmtstr = '{name}:{' + self.display + self.fmt + '},'
        return fmtstr.format(**self.__dict__)


def get_collate_fn(nframe_range):
    def collate_fn(batch):
        min_nframe, max_nframe = nframe_range
        assert min_nframe <= max_nframe
        num_frame = np.random.randint(min_nframe, max_nframe+1)
        pt = np.random.randint(0, max_nframe-num_frame+1)
        batch = [(item[0][..., pt:pt+num_frame], item[1])for item in batch]
        return default_collate(batch)
    return collate_fn


def cycle(dataloader):
    while True:
        for data, label in dataloader:
            yield data, label


def save_model(net, model_path):
    model_dir = os.path.dirname(model_path)
    if not os.path.exists(model_dir):
        os.makedirs(model_dir)
    torch.save(net.state_dict(), model_path)
