FROM bamos/openface

RUN apt-get -y update \
 && apt-get -y install libzbar0 libzbar-dev libopencv-dev libtesseract-dev git cmake build-essential libleptonica-dev liblog4cplus-dev libcurl3-dev beanstalkd \
 && pip install gunicorn bottle zbar numpy Pillow graphviz jupyter

# Install openalpr
ADD openalpr /root/alpr

RUN cd /root/alpr/src \
 && mkdir build \
 && cd build \
 && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_INSTALL_SYSCONFDIR:PATH=/etc .. \
 && make -j2 \
 && make install

RUN cd /root/alpr/src/bindings/python \
 && python setup.py install 
#./make.sh this did not work

# Install mxnet
RUN cd /root \
 && git clone --recursive https://github.com/dmlc/mxnet \
 && cd mxnet \
 && cp make/config.mk config.mk \
 && sed -i 's/USE_BLAS = atlas/USE_BLAS = openblas/g' config.mk \
 && make -j"$(nproc)"

RUN cd /root/mxnet/python && python setup.py install

RUN echo "export PYTHONPATH=$MXNET_HOME/python:$PYTHONPATH" >> /root/.bashrc

# Fix permissions in /root
RUN chmod 777 -R /root

WORKDIR /root

EXPOSE 8888