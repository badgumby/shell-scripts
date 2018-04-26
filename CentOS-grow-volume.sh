################################################################################################
################################################################################################
##
##           This is not a shell script - Just set to .sh for syntax highlighting
##           This just contains the basic instructions to increase a CentOS volume
##
################################################################################################
################################################################################################

###### Step 1 ######
#Increase disk size in vCenter, then extend volume using gParted or
#Add new drive to VM and issue commands below:
lvm pvcreate /dev/sda#
lvm vgextend "GroupName" /dev/sda#

###### Step 2 ######
#Get size of expanded volume group, write down "Free PE / Size"
lvm vgdisplay

###### Step 3 ######
#Get size of logical volume you want to increase, write down "Current LE"
lvm lvdisplay /dev/centos/root

###### Step 4 ######
#Add "Free PE / Size" and "Current LE" together. This is your new_extent_size
lvm lvresize -l new_extent_size /dev/centos/root

###### Step 5 ######
#Once the logical volume has increased, you can grow the file system
xfs_growfs /dev/centos/root

###### Step 6 ######
#Confirm volume is correct size
df -h
