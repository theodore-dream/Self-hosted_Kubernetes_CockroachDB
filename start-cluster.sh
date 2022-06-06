#!

# start cockroachdb nodes

ssh root@ubuntu-worker1 cockroach start --store=/cockroach --insecure --advertise-addr=10.166.133.44 --join=10.166.133.44,10.166.133.163,10.166.133.93 --cache=.25 --max-sql-memory=.25 --background

ssh root@ubuntu-worker2 cockroach start --store=/cockroach --insecure --advertise-addr=10.166.133.163 --join=10.166.133.44,10.166.133.163,10.166.133.93 --cache=.25 --max-sql-memory=.25 --background

ssh root@ubuntu-worker3 cockroach start --store=/cockroach --insecure --advertise-addr=10.166.133.93 --join=10.166.133.44,10.166.133.163,10.166.133.93 --cache=.25 --max-sql-memory=.25 --background

# have worker1 initiatize the cluster

ssh root@ubuntu-worker1 cockroach init --insecure --host=10.166.133.163,10.166.133.93

# run a test

ssh root@ubuntu-worker1 cockroach sql --insecure --host=10.166.133.44 SHOW DATABASES;
