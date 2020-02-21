SYSTEMD_PATH="/etc/systemd/system"

NGINX_CONFIG_PATH="/etc/nginx"

scp -r "files" hichat:~


ssh midterm << EOF
	create_user(){
        echo "Creating hichat..."
        sudo useradd -p $(openssl passwd -1 disabled) hichat
        echo "Complete"
    }

    install_package(){
        echo "Installing packages..."
        sudo yum -y update
        sudo yum -y install git nodejs npm nginx 
        sudo systemctl enable mongod
        sudo systemctl start mongod
        echo "Complete"
    }

    config_firewall(){
        echo "Configuring firewall..."
        sudo firewall-cmd --zone=public --add-service=http
        sudo firewall-cmd --zone=public --add-port=3000/tcp
        sudo firewall-cmd --runtime-to-permanent
        echo "Complete"
    }

    setup_app(){
        echo "Set up app"
        sudo chmod 755 /home/hichat
        sudo rm -rf /home/hichat/app
        git clone https://github.com/wayou/HiChat.git app
        cd app
        sudo npm install 
        cd ~
        sudo mv -f app /home/hichat
        sudo chown hichat /home/hichat/app
        cd ~
        sudo cp -f files/nginx.conf "$NGINX_CONFIG_PATH"
        sudo cp -f files/hichat.service "$SYSTEMD_PATH"
        
        sudo systemctl enable nginx
        sudo systemctl restart nginx
        sudo systemctl daemon-reload
        sudo systemctl enable hichat
        sudo systemctl restart hichat
        echo "Complete"
    }

create_user
install_package
config_firewall
setup_app
exit
EOF