#!/bin/bash
# Initiated from ssh-keys.sh

# NOTE: This will actually have to be different depending on what the results of
# server-locations.sh. Also, it is possible that workstations will not recognize
# the "expect" command. May have to define it, or include it with the package

# Includes
source includes.sh

# Set Variables
sourceIP=$(cat $path/full-migration/source-files/sourceIP)
sourceUSER=$(cat $path/full-migration/source-files/sourceUSER)
sourcePASS=$(cat $path/full-migration/source-files/sourcePASS)
sourcePORT=$(cat $path/full-migration/source-files/sourcePORT)

# SSH Keys Setup
# Credit goes to ehowe for this

sshkeys () {
        if ! [ -f ~/.ssh/id_rsa ]
        then ssh-keygen -t rsa -q -N "" -V +2w -f ~/.ssh/id_rsa
        fi
}

# Source Server Login
sourceserverlogin () {
        KEY=`cat /root/.ssh/id_rsa.pub`
        expect_output=$(expect -c "
        send_user \"connecting to $sourceIP\n\"
        spawn ssh -o StrictHostKeyChecking=no $sourceUSER@$sourceIP -p$sourcePORT
        #login handles cases:
        #   login with keys (no user/pass)
        #   user/pass
        #   login with keys (first time verification)
        expect {
                \"> \" { } 
                \"$ \" { }
                \"assword: \" { 
                send \"$sourcePASS\n\" 
                expect {
                        \"> \" { }
                        \"$ \" { }
                        \"# \" { }
                        }
                }
                default {
                send_user \"Login failed\n\"
                exit
                }
        }
        send \"mkdir -p ~/.ssh\n\"
        expect {
                \"> \" {}
                \"# \" {}
                default {} 
        }
        send \"echo $KEY >> ~/.ssh/authorized_keys\n\"
        expect {
                \"> \" {} 
                \"# \" {}
                default {}
        }
        send \"exit\n\"
        expect {
                \"> \" {}
                \"# \" {}
                default {} 
        }
        send_user \"finished\n\"
        ")
        echo "$expect_output"
}

menu_prep
export text1="Setting up SSH keys with source server ..."
submenu

# Setup SSH Key
sshkeys 2>&1 /dev/null

# Login to source server
sourceserverlogin 2>&1 /dev/null

# Script end. Returns to ssh-keys.sh
