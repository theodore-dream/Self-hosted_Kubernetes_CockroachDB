#!

multipass launch --name ubuntu-worker1 --cpus 4 --mem 8G --disk 20G
multipass launch --name ubuntu-worker2 --cpus 4 --mem 8G --disk 20G
multipass launch --name ubuntu-worker3 --cpus 4 --mem 8G --disk 20G

multipass mount /home/admin/Documents/multipass_env/ubuntu-roach-cluster/cockroach ubuntu-worker1:/cockroach
multipass mount /home/admin/Documents/multipass_env/ubuntu-roach-cluster/cockroach ubuntu-worker2:/cockroach
multipass mount /home/admin/Documents/multipass_env/ubuntu-roach-cluster/cockroach ubuntu-worker3:/cockroach

echo "complete"
