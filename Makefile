ansible_galaxy:
	ansible-galaxy install -r ansible/requirements.yml

build_centos7:
	packer build centos7.yml

all: ansible_galaxy build_centos7
