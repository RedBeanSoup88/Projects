#/bin/bash
#Lim Hian Kok (S17) - CFC 2407 - James Lim

#	This function updates and upgrades the current system to the latest version.
function updateupgrade ()
{
	
	echo '-------------------------  Update and Ugrade System  -------------------------'
	
	#	This command will get all the information on the latest version of packages that are available for the user's system.
	sudo apt-get -y update

	#	This command will download and install all the latest version of the required packages to upgrade the user's system to the latest version available.
	sudo apt-get -y upgrade
	
	echo '-------------------  Upgrade and Upgrade System Completed  -------------------'
}

#	This function download and installs all the tools required to run the script.
function installtools ()
{
	
	echo '--------------------------  Installation of Tools  ---------------------------'

	#	This command will install geany onto the system in the event there is a need for user to amend certain commands to meet their needs.
	sudo apt-get -y install geany

	#	This command will install sshpass capabilities for connection to remote servers.
	sudo apt-get -y install sshpass
	
	echo '---------------------  Installation of Tools Completed  ----------------------'
	
}

#	This function install Nipe services onto the system.
function installnipe ()
{
	# 	This command is to navigate to the users Desktop everytime it needs to install Nipe services.
	cd ~/Desktop
	
	echo '---------------------------  Installation of Nipe  ---------------------------'
	
	#	This command clone the repository from GitHub onto the system.
	git clone https://github.com/htrgouvea/nipe
	
	#	This command is to navigate into the Nipe directory before executing the next command.
	cd ~/Desktop/nipe
	
	#	This command installs the libraries and dependencies required to run Nipe services.
	#	Learned how to auto response "yes" response when installaing programs from https://stackoverflow.com/questions/7642674/how-do-i-script-a-yes-response-for-installing-programs
	yes | sudo cpan install Try::Tiny Config::Simple JSON

	#	This command installs the Nipe dependencies onto the user's system.
	sudo perl nipe.pl install	
	
	echo '----------------------  Installation of Nipe Completed  ----------------------'
	
}

#	This function checkes the Nipe services and make sure the connection of the user is masked.
function checkconn ()
{	

	#	This command is to navigate into the Nipe directory before executing the next command.
	cd ~/Desktop/nipe
	
	echo '-------------------------  Checking Nipe Connection  -------------------------'
	
	#	This command is to stop the Nipe services (if it is already started).
	sudo perl nipe.pl stop
	
	#	This command stores the original external IP address into the variable "myip" (for reference).
	myip=$(curl -s ifconfig.io/ip)
	
	#	This command displays the user's original external IP address.
	echo "The original External IP is : $myip"
	
	#	This command starts the Nipe services on the system.
	sudo perl nipe.pl start
	
	#	This command checks the Nipe services status and prints out result.
	sudo perl nipe.pl status
	
	#	This command stores the result of the Nipe services status (to look specifically for the word "activated.") into the variable "nipestatus".
	nipestatus=$(sudo perl nipe.pl status |grep activated. |awk -F: '{print $2}')

	#	This command stores the current External IP (after starting Nipe services) into the variable "newip".	
	newip=$(curl -s ifconfig.io/ip)

	#	This if command checks if the Nipe services status has been activated.		
	if [ $nipestatus == activated. ]
	
		then		
			#	This command executes when the first 'if' condition is met. 
			#	This if command checks if the current External IP (stored in "newip")is NOT the same as the original External IP (stored in "myip").
			if	[ $newip != $myip ]
			
				#This command executes when the second 'if' conditions is met.
				then
			
					#	This command will check to see what is the country code for the current network, and save it under the variable "CC".
					CC=$(curl -s ifconfig.io/country_code)
					
					#	This command displays the newly masked external IP address of the user.
					echo "The current Masked IP is : $newip"
					
					#	This command displays the newly masked country code of the user.
					echo "The current country code of network is : $CC"
					
					echo '---------------------------  Connection is secured  --------------------------'
				
				#	This command executes when the first 'if' condition is met but the second 'if' condition is not met.
				else
					echo '-------------------------  Connection is not secured  ------------------------'
		
					#	This command will restart and run the whole function again from the start.
					checkconn
			fi
			
			#	This command executes when the first 'if' condition is not met.
			else
				echo '-------------------------  Connection is not secured  ------------------------' 
		
				#	This command will restart and run the whole function again from the start.
				checkconn
			
	fi

}
		

#	This function will execute the command required to:
#	(a) access into the remote server, 
#	(b) execute the nmap and whois command from the remote server for any ip as input by user, 
#	(c) copy the output of the nmap and whois command and send back to the host computer
#	(d) remove the output files at the remote server.

function remoteaccess ()
{
	
	#	This command request user to input the IP address of the remote server and save the input in the variable "RSIP"
	echo 'Input Remote server IP address:' && read RSIP
	
	#	This command request user to input the user ID of the remote server and save the input in the variable "RSID"
	echo 'Input Remote server ID:' && read RSID
	
	#	This command request user to input the user password of the remote server and save the input in the variable "RSPW"
	echo 'Input Remote server PW:' && read RSPW
	
	#	This command request user to input the IP address that they want to run the nmap and whois function on and save the input in the variable "IPadd"
	echo 'Please input IP address that you would want to scan: ' && read IPadd
	
	echo '---------------------------  Connecting into Server  --------------------------'

#	Learned how to ssh access from https://www.redhat.com/sysadmin/ssh-automation-sshpass
#	This command will ssh into the intended remote server using the saved details (user password, user ID, IP address) and execute the "nmap" command on the IP address input by the user and save the output at the remote server.	
	sshpass -p $RSPW ssh -o StrictHostKeyChecking=no $RSID@$RSIP "nmap "$IPadd" -oG "$IPadd"_nmap.scan"
	
#	This command will ssh into the intended remote server using the saved details (user password, user ID, IP address) and execute the "whois" command on the IP address input by the user and save the output at the remote server.	
	sshpass -p $RSPW ssh -o StrictHostKeyChecking=no $RSID@$RSIP "whois "$IPadd" > "$IPadd"_whois.scan"
	
#	This command will ssh into the intended remote server using the saved details (user password, user ID, IP address) and execute the "masscan" command on the IP address input by the user and save the output at the remote server.	
	sshpass -p $RSPW ssh -o StrictHostKeyChecking=no $RSID@$RSIP "echo "$RSPW" | sudo -S masscan "$IPadd" -p20-80 -oG "$IPadd"_mass.scan"
	
	echo '-------------------------------  Scan Completed  ------------------------------'	

#	This command will delete a directory with the scanned IP address as the name (if any).	
	rm -r ~/Desktop/$IPadd/*
	
#	This command will create a directory with the scanned IP address as the name.	
	mkdir ~/Desktop/$IPadd

#	Learned how to scp via SSH without the need to input password from https://www.atlantic.net/dedicated-server-hosting/how-to-pass-password-to-scp-command-in-linux/
#	This command will ssh into the intended remote server using the saved details (user password,  user ID, IP address) and copy the saved "nmap" output back to the user computer at the specified location.
	sshpass -p $RSPW scp $RSID@$RSIP:~/"$IPadd"_nmap.scan ~/Desktop/$IPadd
	
#	This command will ssh into the intended remote server using the saved details (user password,  user ID, IP address) and copy the saved "whois" output back to the user computer at the specified location.
	sshpass -p $RSPW scp $RSID@$RSIP:~/"$IPadd"_whois.scan ~/Desktop/$IPadd
	
#	This command will ssh into the intended remote server using the saved details (user password,  user ID, IP address) and copy the saved "masscan" output back to the user computer at the specified location.
	sshpass -p $RSPW scp $RSID@$RSIP:~/"$IPadd"_mass.scan ~/Desktop/$IPadd

#	This command will ssh into the intended remote server using the saved details (user password,  user ID, IP address) and remove the "nmap" output file from the server.  	
	sshpass -p $RSPW ssh -o StrictHostKeyChecking=no $RSID@$RSIP rm "$IPadd"_nmap.scan
	
#	This command will ssh into the intended remote server using the saved details (user password,  user ID, IP address) and remove the "whois" output file from the server. 
	sshpass -p $RSPW ssh -o StrictHostKeyChecking=no $RSID@$RSIP rm "$IPadd"_whois.scan
	
#	This command will ssh into the intended remote server using the saved details (user password,  user ID, IP address) and remove the "masscan" output file from the server. 
	sshpass -p $RSPW ssh -o StrictHostKeyChecking=no $RSID@$RSIP rm "$IPadd"_mass.scan

#	This command will check how many files is inside the newly created directory for the scanned IP address.
	Checkfiles=$(cd ~/Desktop/$IPadd && ls |wc -l)

#	This if command is to check if the number of files in the directory is 1 or more.
	if [ $Checkfiles -ge 1 ]
	
		#	This command executes when the 'if' condition is met.
		then
			echo "-------------------------  $Checkfiles files saved into folder  -------------------------"
		
		#	This command executes when the 'if' command is NOT met.
		else
			echo '--------------------------  0 file saved into folder  -------------------------'
	
	fi
}

#	This function is for user to choose which section of the script do they want to run.
function userinterface ()
{
#	This command is to display the options available for user and request for their choice.
read -p "What would you like to do? 
(A) Update and upgrade your system. 
(B) Install tools for the script
(C) Install Nipe.
(D) Check if connection is secure. 
(E) Access remote server to run Nmap, whois and masscan commands. 
(F) Do everything in the script.
(G) Exit Script." executions

#	This command is to navigate the script accordance to what was input by the user.
case $executions in

	# This command is when a user choose (A) and the script will just run the update and upgrading of the system.
	a | A)
		updateupgrade
		userinterface
	;;

	# This command is when a user choose (B) and the script will just run the installation of required tools.	
	b | B)
		installtools
		userinterface
	;;

	# This command is when a user choose (C) and the script will just run the installation of Nipe services.	
	c | C)	
		installnipe
		userinterface
	;;

	# This command is when a user choose (D) and the script will just run to check if the connection is secure or not.
	d | D)
		checkconn
		userinterface
	;;
	
	# This command is when a user choose (E) and the script will just run for access to the remote server and its functions.
	e | E)
		checkconn
		remoteaccess
		userinterface
	;;

	# This command is when a user choose (F) and the script will run all its function from the beginning.scp
	f | F)
		updateupgrade && installtools && installnipe && checkconn && remoteaccess
		userinterface
	;;

	# This command is when a user choose (G) and the script end.
	g | G)
		
		exit
	;;
	
esac
}

#	This command starts once the script is running. It shows the command line interface where user first choose how they want to run the script.
userinterface
