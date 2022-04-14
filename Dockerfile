ARG CUDA_VERSION=11.6.1

FROM nvcr.io/nvidia/cuda:${CUDA_VERSION}-devel-ubuntu20.04

# install Python
ARG _PY_SUFFIX=3
ARG PYTHON=python${_PY_SUFFIX}
ARG PIP=pip${_PY_SUFFIX}

ARG COLAB_PORT=8081
EXPOSE ${COLAB_PORT}
ENV COLAB_PORT ${COLAB_PORT}

ARG DEBIAN_FRONTEND=noninteractive

# See http://bugs.python.org/issue19846
ENV LANG C.UTF-8

WORKDIR /opt/colab

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get -y dist-upgrade && \
    apt-get install -y ${PYTHON} ${PYTHON}-pip git curl wget ffmpeg libsm6 libxext6 imagemagick python3-numpy && \
    ${PIP} --no-cache-dir install --upgrade pip setuptools && \
    ln -s $(which ${PYTHON}) /usr/local/bin/python && \
    pip install jupyterlab jupyter_http_over_ws ipywidgets google-colab opencv-python Cython "pyzmq==17.0.0" \
    && jupyter serverextension enable --py jupyter_http_over_ws \
    && jupyter nbextension enable --py widgetsnbextension && \
    pip3 install --upgrade ipython

# Cython-0.29.28 MarkupSafe-2.1.1 attrs-21.4.0 beautifulsoup4-4.11.1 bleach-5.0.0 cachetools-5.0.0 certifi-2021.10.8 chardet-3.0.4 decorator-5.1.1 defusedxml-0.7.1 entrypoints-0.4 fastjsonschema-2.15.3 google-auth-1.4.2 google-colab-1.0.0 idna-2.8 importlib-resources-5.6.0 ipykernel-4.6.1 ipython-5.5.0 ipython-genutils-0.2.0 ipywidgets-7.7.0 jinja2-3.1.1 json5-0.9.6 jsonschema-4.4.0 jupyter-client-7.1.2 jupyter-core-4.9.2 jupyter_http_over_ws-0.0.8 jupyterlab-2.3.2 jupyterlab-pygments-0.2.0 jupyterlab-server-1.2.0 jupyterlab-widgets-1.1.0 mistune-0.8.4 nbclient-0.5.13 nbconvert-6.5.0 nbformat-5.3.0 nest-asyncio-1.5.5 notebook-5.2.2 opencv-python-4.5.5.64 packaging-21.3 pandas-0.24.2 pandocfilters-1.5.0 pexpect-4.8.0 pickleshare-0.7.5 portpicker-1.2.0 prompt-toolkit-1.0.18 ptyprocess-0.7.0 pyasn1-0.4.8 pyasn1-modules-0.2.8 pygments-2.11.2 pyparsing-3.0.8 pyrsistent-0.18.1 python-dateutil-2.8.2 pytz-2022.1 pyzmq-17.0.0 requests-2.21.0 rsa-4.8 simplegeneric-0.8.1 six-1.12.0 soupsieve-2.3.2 terminado-0.13.3 tinycss2-1.1.1 tornado-4.5.3 traitlets-5.1.1 urllib3-1.24.3 wcwidth-0.2.5 webencodings-0.5.1 widgetsnbextension-3.6.0 zipp-3.8.0

# install task-specific packages
# If you're not running Disco Diffusion, you can and should remove this block and write your own to fetch the libraries and models you need
RUN pip install sklearn transformers matplotlib && \
    pip install annoy && \
    mkdir -p /content/models && cd /content/models && \
    wget https://github.com/intel-isl/DPT/releases/download/1_0/dpt_large-midas-2f21e586.pt && \
    wget https://v-diffusion.s3.us-west-2.amazonaws.com/512x512_diffusion_uncond_finetune_008100.pt && \
    wget https://v-diffusion.s3.us-west-2.amazonaws.com/secondary_model_imagenet_2.pth && \
    cd /opt/colab && \
    git clone https://github.com/shariqfarooq123/AdaBins.git && \
    cd AdaBins && \
    sed -i 's/.\/pretrained/\/opt\/colab\/pretrained/g' infer.py && \
    cd .. && \
    mkdir -p pretrained && cd pretrained && \
    wget https://cloudflare-ipfs.com/ipfs/Qmd2mMnDLWePKmgfS8m6ntAg4nhV5VkUyAydYBp8cWWeB7/AdaBins_nyu.pt && \
    cd ..
ENV PYTHONPATH "${PYTHONPATH}:/opt/colab/AdaBins"

CMD jupyter notebook \
    --NotebookApp.allow_origin='https://colab.research.google.com' \
    --allow-root \
    --port $COLAB_PORT \
    --NotebookApp.port_retries=0 \
    --ip 0.0.0.0 \
    --NotebookApp.token=$JUPYTER_PASSWORD_FOR_COLAB