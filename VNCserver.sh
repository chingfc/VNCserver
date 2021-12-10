#!/bin/sh

##Chingfc

##This script must be run by ROOT or SUPER USER!

[[ $(id -u) -eq 0 || $(id -u) -eq 1000 ]] || { echo >&2 "Must be root or admin user to run script"; exit 1; }


read -p "Enter Your Username: " name
read -p "Enter Your Port: " port
USER=$name
port=$port
dport=$((5900+$port))
echo "###########################################################################################"
echo "###                                                                                     ###"
echo -e "###\033[32mPlease identify the following information before continuing run the following Script!\033[0m###"
echo "###                                                                                     ###"
echo "###########################################################################################"

echo -e "                              User name: \033[36m$USER\033[0m                                            "
echo -e "                              Port: \033[36m$port\033[0m                                                 "
echo -e "                              Dport: \033[36m$dport\033[0m                                               "

read -p "Is this imformation right (y|n):" flag

if [[ "$flag" =~ ^(Yes|yes|Y|y)$ ]]; then 
 /bin/sh -c "cp /etc/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:$port\.service && \
    sed -i -e 's/<USER>/$USER/g' /etc/systemd/system/vncserver@:$port\.service"

 if [ -f /etc/systemd/system/vncserver@:$port\.service ]; 
   then
      rm /tmp/.X11-unix/* &> /dev/null
      systemctl daemon-reload
      systemctl enable vncserver@:$port &> /dev/null
      systemctl start vncserver@:$port &> /dev/null
      systemctl status vncserver@:$port
      echo "==========================================================================="
      echo -e "====================\033[31mSetting VNC Password for $USER \033[0m========================"
      echo "==========================================================================="
      vncpasswd $USER
      if systemctl status vncserver@:$port | grep active; 
	then
	   # awk '1;/<service name=\"nfs\"\/>/{print "  <port protocol=\"tcp\" port=\""$dport\"/>"}' /etc/firewalld/zones/public.xml > \
           #  /etc/firewalld/zones/tmp.xml
	   # mv -f /etc/firewalld/zones/tmp.xml /etc/firewalld/zones/public.xml
            if ! grep -q $dport /etc/firewalld/zones/public.xml; then	    
	       sed -i -e "/<service name=\"nfs\"\/>/ a\  <port protocol=\"tcp\" port=\"$dport\"/>" /etc/firewalld/zones/public.xml	
	    fi
	    firewall-cmd --reload &> /dev/null
	    echo "Checking whether port add sucessfully!"
	    if firewall-cmd --list-ports | grep $dport; then
	       echo -e "\033[32m Port $dport has been added to firwall!\033[0m"
	       echo -e "\033[32m Great jobs, enjoy your Centos world!\033[0m"
	    else
	       echo -e "\033[31m Fail to add $dport to firewall!\033[0m"		
	    fi

	else
	    echo -e "\033[\e[1;42m---------------OPPs, fail to add port to firewall!\e[0m------------------"
      fi


 else
      echo -e "\033[\e[1;46m -------------vncserver@:$port\.service file not found!-------------------\e[0m"

 fi
else
 echo "Bye for now! Best Wishes!"
 exit 1
fi
