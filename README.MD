Goal is to use a Linux environment running multipass to virtualize Ubuntu to create a 3 node CockroachDB cluster running on Kubernetes

The CockroachDB cluster did not properly initialize when I tested with the Kubernetes Operator. I suspect that I would need to re-configure this with statefulsets in order for it to startup properly.



# first setup 3 Ubuntu VMs

Using multipass create 3 ubuntu instances

```
# running Ubuntu 20.04 or later with at least 2GB RAM and 2vCPUs and 10GB of storage each.

multipass launch --name ubuntu_control --cpus 2 --mem 4G --disk 10G
multipass launch --name ubuntu_worker1 --cpus 2 --mem 4G --disk 20G
multipass launch --name ubuntu_worker2 --cpus 2 --mem 4G --disk 20G
multipass launch --name ubuntu_workspace --cpus 2 --mem 2G --disk 10G

# optionally, also create another VM from which to run commands from using Ansible.
# you can also run those commands your Linux host.
ubuntu_control
ubuntu_worker1
ubuntu_worker2

```

Unsure if it is required to mount but it makes sense to me. This will be a prerequisite to later configuration of statefulsets

```
# do a mount on multipass to create persistent volumes
# syntax
multipass mount /path-to-local-folder <name-of-vm>:/path-on-vm

# example syntax

multipass mount /Users/theodore/Documents/Coding/multipass/cockroach/roach1 ubuntu-worker1:/cockroach
multipass mount /Users/theodore/Documents/Coding/multipass/cockroach/roach2 ubuntu-worker2:/cockroach

```

tip: if you hit any issues with multipass, this can be a helpful command to run to check logs.

```
journalctl --unit 'snap.multipass*'
```

# setup of ssh keys

This method of setting up and exchanging ssh keys is only appropriate for a development testing environment. Definitely not recommended if you are exposing your VM environment to the internet.

On workspace, create /etc/hosts with "multipass list" info

```
vim /etc/hosts

# example IPs
192.168.64.7 ubuntu-control
192.168.64.8 ubuntu-worker
192.168.64.9 ubuntu-worker2
192.168.64.6 ubuntu-workspace
```

on all systems, create root passwords

```
sudo passwd root
root
```

on all systems, set password auth on and restart sshd

```
vim /etc/ssh/sshd_config
PermitRootLogin yes
PasswordAuthentication yes
```

```
sudo systemctl restart sshd
```

from workspace share ssh keys

```
ssh-keygen
```

then run this command to all nodes

```
sudo ssh-copy-id -i .ssh/id_rsa.pub root@ubuntu-control
sudo ssh-copy-id -i .ssh/id_rsa.pub root@ubuntu-worker
sudo ssh-copy-id -i .ssh/id_rsa.pub root@ubuntu-worker2
```

then you are ready to run the ansible script from the below tutorial


# Kubernetes setup

The setup of the Kubernetes environment was following this (tutorial)[https://www.digitalocean.com/community/tutorials/how-to-create-a-kubernetes-cluster-using-kubeadm-on-ubuntu-20-04]

cluster overview:

- one control plane node
    - running etc and other mgmt stuff
- two worker nodes
    - running the worker pods
- one addition “workspace” node to setup the other nodes with ansible


environment:

- ubuntu_workspace - workspace
- ubuntu_control - control plane node
- ubuntu_worker1 - worker1
- ubuntu_worker2 - worker2

sample host file

```
[control_plane]
control1 ansible_host=control_plane_ip ansible_user=root

[workers]
worker1 ansible_host=worker_1_ip ansible_user=root
worker2 ansible_host=worker_2_ip ansible_user=root

[all:vars]
ansible_python_interpreter=/usr/bin/python3
