
#!/usr/bin/sh
chrootPath="/chroot/dropbear"

echo "[*] Stopping old Dropbear instances..."
pidof dropbear | xargs kill -9

echo "[*] Starting telnetd..."
mkdir -p /dev/pts
mountpoint -q /dev/pts || mount -t devpts none /dev/pts
busybox telnetd -F &

echo "[*] Checking chroot environment..."
if [ ! -d "$chrootPath/etc/dropbear" ]; then
    echo "[*] Creating chroot directory structure..."
    mkdir -p ${chrootPath}/{dev/pts,proc,etc/dropbear,lib,usr/lib,var/run,var/log}
    echo "[*] Generating SSH host keys if missing..."
    [ ! -f /etc/dropbear/dropbear_dss_host_key ] && \
        dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key
    [ ! -f /etc/dropbear/dropbear_rsa_host_key ] && \
        dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key
    
    echo "[*] Copying host keys and binary..."
    cp /etc/dropbear/dropbear_*_host_key ${chrootPath}/etc/dropbear/
    cp /am7x/bin/dropbear ${chrootPath}/etc/dropbear/
    
    echo "[*] Copying libraries..."
    cp /lib/libcrypt.so.1 ${chrootPath}/lib/
    cp /lib/libutil.so.1 ${chrootPath}/lib/
    cp /am7x/lib/libz.so.1 ${chrootPath}/lib/
    cp /lib/libc.so.6 ${chrootPath}/lib/
    cp /lib/ld.so.1 ${chrootPath}/lib/
    
    echo "[*] Copying resolver config..."
    cp /etc/resolv.conf ${chrootPath}/etc/
    
    echo "[*] Creating device nodes..."
    mknod -m 666 ${chrootPath}/dev/urandom c 1 9
    mknod -m 666 ${chrootPath}/dev/ptmx    c 5 2
    mknod -m 666 ${chrootPath}/dev/tty     c 5 0
    
    echo "[*] Touching log files..."
    touch ${chrootPath}/var/log/lastlog
    touch ${chrootPath}/var/run/utmp
    touch ${chrootPath}/var/log/wtmp
fi

echo "[*] Mounting devpts and proc inside chroot..."
mountpoint -q ${chrootPath}/dev/pts || mount -o bind /dev/pts ${chrootPath}/dev/pts
mountpoint -q ${chrootPath}/proc    || mount -o bind /proc ${chrootPath}/proc

echo "[*] Starting Dropbear in chroot..."
chroot ${chrootPath} /etc/dropbear/dropbear \
    -d /etc/dropbear/dropbear_dss_host_key \
    -r /etc/dropbear/dropbear_rsa_host_key \
    -m -w -g &

echo "[*] Done. Telnet + Dropbear running."
