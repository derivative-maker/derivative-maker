##################
## INTRODUCTION ##
##################

This document is wirtten as a guide for setting up and tailoring Whonix for Linux libvirt. libvirt is a feature rich virtualization API that can enable you to set up the disk image to be used with other containment mechanisms provided on Linux. The ones we currently support are KVM, and qemu-system-x86_64.

Please read instructions carefully, and heed the advice in the Security Warning section.



######################
## SECURITY WARNING ##
######################

IMPORTANT: Before peforming an upgrade to your current Whonix setup, you are advised to shutdown any running Whonix instance currently attached to the internal virtual network named 'Whonix'. This is required to prevent cross contamination of the new machines you are importing, in the event that a powerful adversary has taken control over the ones currently in use.

Note: This is not required if you intend to create a new virtual network for the machines you are importing now.



#######################
## PREPARATION STEPS ##
#######################

If you plan to do any non default changes to the XML configurations, its simpler to do so before the importing step. This is necessary should an alternate location for the disk image files be chosen. You could always edit the XML files later too, if needed as shown in the EXTRA section.

Now is the optimum time to add values from the ALTERNATIVE CONFIGURATIONS section below to change containment type.



###################################
## IMPORTING WHONIX VM TEMPLATES ##
###################################

The supplied XML files serve as a description for libvirt, that tell it what properties a Whonix machine and networking it should have.

1. First we will start with Whonix Gateway:

cd /path/extracted/Whonix-Gateway

su

virsh define whonix_gateway.xml


2. Followed by the Whonix isolated internal network (XML also in the same folder as Whonix Gateway):

virsh net-define whonix_network.xml

virsh net-autostart Whonix

virsh net-start Whonix


3. Lastly the Whonix Workstation:

cd /path/extracted/Whonix-Workstation

virsh define whonix_workstation.xml



###############################
## MOVING WHONIX IMAGE FILES ##
###############################

The XML files are configured to point to the default storage location of: /var/lib/libvirt/images These steps will show how to move the images there in order for the machines to boot. 

Note:  Its possible to tell libvirt a different non-default path for disk images, but this will require editing of the XML files.

sudo mv /path/extracted/Whonix-Gateway/Whonix-gateway.qcow2 /var/lib/libvirt/images


Whonix disk images are sparse files, meaning they expand when filled rather than allocating their entire size, 100GB outright. These are known as sparse files and need special commands hen copying them to ensure they don't lose this property, leading them to occupy all the actual space. If copying to a priviledged location in the system run with higher priledges. Copying the image files by running:

cp --sparse=always /current/location/Whonix_Gateway.qcow2 /new/location/Whonix_Gateway.qcow2



################################
## ALTERNATIVE CONFIGURATIONS ##
################################

By default the templates distributed are for KVM, to run alternative configurations like qemu-system-x86_64 (and qemu-system-arm in the future) Editing an xml could b done by simply opening in any GUI based text editor or running this command and add:

sudo nano whonix_gateway.xml


Change:

<domain type='kvm'>

to

<domain type='qemu'>



###########
## EXTRA ##
###########


KVM Shared Folders

To move data between the guest and host follow these steps:

1. Set the following settings for shared folders in virt-manager:

The file sharing mode 'mapped' is just an example, using squash or passthrough is possible by selecting them from the drop down menu.

Driver:Default
Mode: Mapped

Source Path: [This is the path of the folder on the Host you are sharing with the Guest]
Target Path: [A custom tag for the shared directory that is used when running the mounting commands within the guest. for example: /tmpshare]


2. Run terminal as root in Guest then use the following command:

mount -t 9p -o trans=virtio [mount tag] [mount point] -oversion=9p2000.L

Mount tag is: /tmpshare
Mount point is the path of the directory that you will share in the Guest with the Host. If it doesn't exist you must create that folder.


Note: you replace the parentheses in the command, they are just a placeholder in this example and should not be typed in.

3. To automatically mount this every time at boot, add the following to your guest's /etc/fstab:

sudo nano /etc/fstab [mount tag] [mount point] 9p trans=virtio,version=9p2000.L,rw 0 0 


Note: If your system is configured to use a Mandatory Access Control framework like Apparmor, you may need to configure an exception rule to allow the confined guests to communicate with the designated shared folder on the guest. Do NOT be tempted to disable Apparmor to get this working, as it removes a critical protection layer that protects your host. Be patient and read the documentation.



Editing Already Imported Machine's XML:

su

EDITOR=nano virsh edit Whonix-Gateway


Enabling SPICE

SPICE allows accelerated graphics and clipboard sharing. 
Install vdagent in guest and reboot. 
