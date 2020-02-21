#vbmg () { /mnt/c/Program\ Files/Oracle/VirtualBox/VBoxManage.exe "$@"; }
vbmg () { C:/Program\ Files/Oracle/VirtualBox/VBoxManage.exe "$@"; }


NET_NAME="NETMIDTERM"
OLD_VM_NAME="MIDTERM4640"
VM_NAME="A01058543"
SSH_PORT="12922"
WEB_PORT="12980"

clean_all () {
	vbmg natnetwork remove --netname "$NET_NAME"
    vbmg modifyvm "$VM_NAME" --name "$OLD_VM_NAME"
}

create_network () {
    vbmg natnetwork add --netname "$NET_NAME" --network 192.168.10.0/24 \
    --enable

    vbmg natnetwork modify --netname "$NET_NAME" --dhcp off\
    --port-forward-4 "my_rule:tcp:[127.0.0.1]:$SSH_PORT:[192.168.10.10]:22"\
    --port-forward-4 "my_rule2:tcp:[127.0.0.1]:$WEB_PORT:[192.168.10.10]:80"
}

modify_vm() {
	vbmg modifyvm "$OLD_VM_NAME" --name "$VM_NAME"
	vbmg modifyvm "$VM_NAME" --nic1 natnetwork --nat-network1 "$NET_NAME"
}

start_vm() {
	vbmg startvm "VM_NAME"
}

echo "Starting script..."

clean_all
create_network
modify_vm
start_vm
ssh midterm << EOF

echo "success"

EOF

echo "DONE!"