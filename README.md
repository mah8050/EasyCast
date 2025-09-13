EasyCast Device Access and Enhancement Guide
This guide shows how to gain access to an EasyCast device (AM8251 CPU), perform firmware updates, enable SSH/Telnet, and set up basic web controls for media playback.
Disclaimer: Do not distribute official firmware files. Use this guide only on devices you own. Proceed at your own risk.
________________________________________
1. Gain Access via UART
1.	Locate the exposed Rx, Tx, and GND pins on the board.
2.	Connect them to a USB-to-UART adapter (e.g., PL2303 or FT232).
3.	Set the baud rate to 115200.
________________________________________
2. Connect Device via USB
1.	Connect the device to your PC using its USB cable.
2.	Open a terminal program (e.g., PuTTY) or any serial port viewer.
Important: If the device is not connected via USB and Wi-Fi dongle, it will reboot every 1 minute.
3.	You should see a login prompt:
o	Username: root
o	Password: am2016
________________________________________
3. Firmware Update (Optional)
1.	Start a simple web server on your PC:
2.	python sw.py
3.	Put the firmware update file in the same folder as sw.py.
4.	On the device console, run:
5.	/usr/ota_from http://[your_local_ip]/[update_file_name]
6.	Wait for the device to update and reboot.
________________________________________
4. Enable Telnet and SSH
1.	On the device, run:
2.	/am7x/case/scripts/start_ssh_service.sh
3.	To make SSH/Telnet always start on boot, add the command to /etc/init.d/rcS:
4.	/am7x/case/scripts/start_ssh_service.sh
5.	Alternatively, you can use the dropbear_start.sh script:
o	Copy dropbear_start.sh to /etc/init.d/
o	Make it executable:
o	chmod +x /etc/init.d/dropbear_start.sh
o	Add the script to the end of /etc/init.d/rcS:
o	/etc/init.d/dropbear_start.sh
________________________________________
5. Set Up Web Access for Media Playback
1.	Copy cast-control.sh to /root and make it executable.
2.	Copy the following scripts to the HTTP CGI folder:
o	play.sh → /mnt/user1/thttp/http/cgi-bin/
o	control.sh → /mnt/user1/thttp/http/cgi-bin/
3.	Copy the index.html from the repository to /mnt/user1/thttp/http/.
o	Rename the original index.html (e.g., index2.html) if needed.
You can now access the device via its IP address in a browser and control video playback using the web interface.

