Goal is to use a Linux environment running multipass to virtualize Ubuntu to create a 3 node CockroachDB cluster running on Kubernetes

The CockroachDB cluster did not properly initialize when I tested with the Kubernetes Operator. I suspect that I would need to re-configure this with statefulsets in order for it to startup properly.



# first setup 3 Ubuntu VMs

Using multipass create 3 ubuntu instances

```

multipass launch --name ubuntu_control --cpus 2 --mem 4G --disk 10G
multipass launch --name ubuntu_worker1 --cpus 2 --mem 4G --disk 10G
multipass launch --name ubuntu_worker2 --cpus 2 --mem 4G --disk 10G
multipass launch --name ubuntu_workspace --cpus 2 --mem 4G --disk 10G

# optionally, also create another VM from which to run commands from. # you can also run those commands your Linux host.
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
multipass mount /Users/theodore/Documents/Coding/multipass/cockroach ubuntu:/cockroach
```

tip: if you hit any issues with multipass, this can be a helpful command to run to check logs.

```
journalctl --unit 'snap.multipass*'
```

- requirements
    - Three servers running Ubuntu 20.04 with at least 2GB RAM and 2 vCPUs each. You should be able to SSH into each server as the root user with your SSH key pair. 
    - One other Ubuntu 20.04+ to run ansible as Workspace


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
