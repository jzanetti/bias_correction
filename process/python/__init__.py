from os.path import exists
from os import makedirs

TMP_DIR = "/tmp/bias_correction"

if not exists(TMP_DIR):
    makedirs(TMP_DIR)
