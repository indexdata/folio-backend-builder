For starting the infrastructure and Okapi, the user needs permissions for running the Docker container.
Without the permissions this message can occur.

`docker: Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Post http://%2Fvar%2Frun%2Fdocker.sock/v1.35/containers/create: dial unix /var/run/docker.sock: connect: permission denied. See 'docker run --help'.`

The container could be run with sudo instead, but the more convenient work-around is to add the user to the Docker group

Create the docker group if it does not exist

`$ sudo groupadd docker`

Add your user to the docker group.

`$ sudo usermod -aG docker $USER`

Log in to the new docker group (to avoid having to log out / log in again; but if not enough, try to reboot):

`$ newgrp docker`

Check if docker can be run without root

`$ docker run hello-world`

Reboot if still getting the error and try hello-world again

