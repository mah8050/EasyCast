
# EasyCast AM8251 Tools

Scripts and guides to access and enhance EasyCast devices powered by the AM8251 CPU. This includes firmware updates, enabling Telnet/SSH, and adding simple web-based media control.

> **Disclaimer:** This repository **does not include proprietary firmware files**. Use only on devices you own and comply with local laws regarding reverse engineering and firmware modifications. Use at your own risk.

---

## Features

- UART and USB access to the device  
- Firmware update via local web server  
- Enable Telnet and SSH with persistent startup  
- Simple web interface for media playback control  

---

## Getting Started

### 1. Gain Access via UART

1. Locate the exposed **Rx**, **Tx**, and **GND** pins on the device.  
2. Connect them to a USB-to-UART adapter (e.g., **PL2303** or **FT232**).  
3. Set the **baud rate** to **115200**.

---

### 2. Connect Device via USB

1. Connect the device to your PC using its USB cable.  
2. Open a terminal program (e.g., **PuTTY**) or any serial viewer.  

> **Note:** The device reboots every 1 minute if not connected via USB and Wi-Fi dongle.

3. Login credentials:  
   - **Username:** `root`  
   - **Password:** `am2016`

---

### 3. Firmware Update (Optional)
If you're using version lower that 17957001 to have telnet you must update
firmware can be downloaded from http://cdn.iezcast.com/upgrade/ezcast/official/ezcast_official-17957001.gz
1. Start a simple web server on your PC:
   ```bash
   python sw.py
   ```
2. Place the firmware update file in the same folder as `sw.py`.  
3. On the device console, run:
   ```bash
   /usr/ota_from http://[your_local_ip]/[update_file_name]
   ```
4. Wait for the device to update and reboot.

---

### 4. Enable Telnet and SSH

1. Run the SSH service script:
   ```bash
   /am7x/case/scripts/start_ssh_service.sh
   ```
2. To make SSH/Telnet start on boot, add this command to **`/etc/init.d/rcS`**:
   ```bash
   /am7x/case/scripts/start_ssh_service.sh
   ```

3. Using `dropbear_start.sh` script (alternative):
   - Copy to `/etc/init.d/`  
   - Make executable:
     ```bash
     chmod +x /etc/init.d/dropbear_start.sh
     ```
   - Add to the end of **`/etc/init.d/rcS`**:
     ```bash
     /etc/init.d/dropbear_start.sh
     ```

---

### 5. Web Access for Media Playback

1. Copy `cast-control.sh` to `/root` and make it executable.  
2. Copy scripts to the HTTP CGI folder:
   ```text
   play.sh       → /mnt/user1/thttp/http/cgi-bin/
   control.sh    → /mnt/user1/thttp/http/cgi-bin/
   ```
3. Copy `index.html` from the repository to `/mnt/user1/thttp/http/`.  
   - Rename the original index.html if needed (e.g., `index2.html`).

> You can now control media playback through your browser by visiting the device IP address.

---

## Contributing

Contributions are welcome! Please avoid sharing firmware binaries or any proprietary content.

---

## License

MIT License – see LICENSE file for details.

