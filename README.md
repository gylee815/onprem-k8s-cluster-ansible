# onprem-k8s-cluster-ansible
ansible to create k8s cluster on onpremise server

## Docker volume mount on windows

docker run -it -v [DOCKER_VOL_ANEM]:[DOCKER_DIR] [DOCKER_IMAGE]
ex> docker run -it -v test:/home/ansible  ansible_rocky:0.1 /bin/bash


## Docker bind mount on windows

docker run -it -w [DOCKER_DIR] -v "//c/[PATH_FOR_LOCAL_DIR]" [DOCKER_IMAGE]
ex> docker run -it -w /home/ansible -v "//c/Users/User/Documents/Work/Docker/ansible/
