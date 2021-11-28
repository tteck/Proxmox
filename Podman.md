<p align="center"><img src="https://podman.io/images/podman.svg" /></p>

Podman is a daemonless container engine for developing, managing, and running OCI Containers on your Linux System. Similar to Docker, Podman is an open source project. Anybody can check out the source code for the program. Contrary to Docker, Podman does not require a daemon process to launch and manage containers. This is an important difference between the two projects.

Podman seeks to improve on some of Docker’s drawbacks. For one, Podman does not require a daemon running as root. In fact, Podman containers run with the same permissions as the user who launched them. This addresses a significant security concern, although you can still run containers with root permissions if you really want to.

Podman seeks to be a drop-in replacement for Docker as far as the CLI is concerned. The developers boast that most users can simply use alias docker=podman and continue running the same familiar commands. The container image format is also fully compatible between Docker and Podman, so existing containers built on Dockerfiles will work with Podman.

Another key difference is that, it handles running containers, but not building them (non-monolithic). The goal here is to have a set of container standards that any application can be developed to support, rather than relying on a single monolithic application such as Docker to perform all duties.

https://www.liquidweb.com/kb/podman-vs-docker/ ___ https://github.com/containers/podman-compose ___ https://podman.io/
