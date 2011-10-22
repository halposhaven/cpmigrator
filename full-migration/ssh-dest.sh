#!/bin/bash
# This script is initiated from ssh-keys.sh

# NOTE: This will actually have to be different depending on what the results of
# server-locations.sh. Also, it is possible that workstations will not recognize
# the "expect" command. May have to define it, or include it with the package

# Includes
source includes.sh

# Set Variables
destinationIP=$(cat $path/full-migration/destination-files/destinationIP)
destinationUSER=$(cat $path/full-migration/destination-files/destinationUSER)
destinationPASS=$(cat $path/full-migration/destination-files/destinationPASS)
destinationPORT=$(cat $path/full-migration/destination-files/destinationPORT)

# Source Server Login
destserverlogin () {
        KEY=`cat /root/.ssh/id_rsa.pub`
        expect_output=$(expect -c "
        send_user \"connecting to $destinationIP\n\"
        spawn ssh -o StrictHostKeyChecking=no $destinationUSER@$destinationIP -p$destinationPORT
        #login handles cases:
        #   login with keys (no user/pass)
        #   user/pass
        #   login with keys (first time verification)
        expect {
                \"> \" { } 
                \"$ \" { }
                \"assword: \" { 
                send \"$destinationPASS\n\" 
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
export text1="Setting up SSH key with destination server..."
submenu

# Setup SSH Key
sshkeys 2>&1 /dev/null

# Login to source server
destserverlogin 2>&1 /dev/null

# Script end. Returns to ssh-keys.sh
