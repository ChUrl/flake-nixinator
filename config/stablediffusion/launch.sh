#!/bin/bash

# NOTE: This script is used in conjunction with the rocm/python docker image

# Install if necessary
if [[ ! -f "/webui-data/stable-diffusion-webui/launch.py" ]]; then
  cd /webui-data
  git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui
  cd stable-diffusion-webui
  python -m pip install --upgrade pip wheel
fi

cd /webui-data/stable-diffusion-webui
REQS_FILE='requirements.txt' python launch.py --precision full --no-half
