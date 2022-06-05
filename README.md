# helecloud_app



To mount EFS file to instance, run the commands below:

1.  `ssh -I <key> ec2-user@<bastion instance_ip>`
2.  `ssh -I <key> ec2-user@<instance_ip>`
3.  `sudo su -`
4.  `mkdir /efs`
5.  `mount -t nfs4 -o nfsvers=4.1,rsize=1048576, wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-ed989e59.efs.eu-west-1.amazonaws.com:/ /efs`
6.  `df -h`
7.  `touch /efs/a`
8.  `ls /efs`
