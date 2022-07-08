From rockylinux:8.5
MAINTAINER gylee

RUN yum -y install epel-release && yum -y update
RUN yum install -y ncurses
RUN yum -y groupinstall "Development Tools" && yum -y install openssl-devel bzip2-devel libffi-devel xz-devel
RUN yum -y install wget
WORKDIR /home
RUN wget https://www.python.org/ftp/python/3.8.12/Python-3.8.12.tgz
RUN tar xvf Python-3.8.12.tgz

WORKDIR Python-3.8.12/
RUN ./configure --enable-optimizations
RUN make altinstall

WORKDIR /home
RUN rm -rf Python-3.8.12.tgz
RUN pip3.8 install ansible