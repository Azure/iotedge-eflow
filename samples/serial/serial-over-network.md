# Connecting to serial port over network

Suppose in a workflow, you have an application that works with some devices attached to serial ports. When moving the workflow to run on the EFLOW VM, you have problems accessing serial ports since the EFLOW VM is isolated from serial ports attached to the Windows host. This article describes how to configure the EFLOW VM and host to redirect communications to a serial port over the network. With the redirection, applications running on EFLOW VM can communicate with devices attached to serial ports (USB serial ports included) on the host.


## The scenario

You have some devices like sensors or Modbus compatible devices connected to serial ports on your host (the **server**), and you want to make use of those devices in applications running on EFLOW VM (the **client**).

Since the client and server are both connected to a Hyper-V virtual switch, we can redirect the communications to a serial port over the network.  The application running on the client only knows how to interact with a serial port, so the client has to have some virtual serial ports for the application.  The client needs the capability to redirect the traffic to/from the virtual serial port to a network socket that connects to the server and, of course, the server information to establish the network socket connection.

On the other end, the server needs to listen to the assigned port, waiting for the client's request to establish a network connection and relay the network communication to/from the physical serial port.

The following diagram shows the architecture described:
```
           Client                                                              Server
      +-------------+
      | Application |  
      +-------------+
             |
             | virtual serial port  
+------------------------+                                            +------------------------+
|  serial/network relay  | ................ (network) ................|  network/serial relay  |
+------------------------+                                            +------------------------+
                                                                                  | physical serial port
                                                                                  |
                                                                          +---------------+
                                                                          | serial device |
                                                                          +---------------+
```

We can summarize the requirements:
- For client:
    - A virtual serial port that mimics a physical serial port and works with the application.
    - Software to redirect the communications to/from the virtual serial port and make serial data available on a TCP/IP network.
    - Host connection information (IP address and TCP port number).

- For server:
    - Software to listen to the pre-assigned port and establish a connection to the client.
    - Relay the communications to/from the client with the serial device through a physical serial port.


## Configure serial over network on EFLOW

Use socat on the client, we configure socat to create a pseudo-ttyS as the device and associate the pseudo-ttyS device with a network port. A pseudo-tty is like a serial port in that it has a /dev entry that can be opened by a program that expects a serial port device, except that instead of belonging to a physical serial device, the data can be intercepted by another program. The socat program intercepts the traffic to/from this pseudo-ttyS and relays the network port data.

Use hub4com from the [com0com project](https://sourceforge.net/projects/com0com/files/hub4com/2.1.0.0/) on the server-side. We setup hub4com to associate the network port with the physical serial port, hub4com listens to the assigned port, establishes a connection to the client, and relays data from network port to physical port.

Here is an example EFLOW configuration

- Host ip = **172.18.246.137**
- Host tcp port = **5002**
- Host physical serial port = **COM3**

- Client virtual serial port name = **/dev/ttyVirtS0**


### Setup Host
- Download and extract hub4com-2.1.0.0-386.zip from [com0com project](https://sourceforge.net/projects/com0com/files/hub4com/2.1.0.0/) to a local directory, e.g. c:\hub4com
- Pick a TCP port number to associate to the serial port planned to expose.  In our example environment, we use port number 5002, and the port is associated with COM3
    > If you have a firewall enabled, explicitly configure the firewall rule to allow inbound traffic for TCP port 5002.  Or run the command in the next step and allow access when asked.
- Run hub4com in server mode, open a command prompt, type `cd /d c:\hub4com` and `com2tcp.bat \\.\COM3 5002` where **COM3** is the physical serial port name and **5002** is the TCP port number.  Click 'Allow access' if the Windows Defender Firewall dialog box pops up and asks for port access.
- Hub4Com starts in server mode waiting for a connection.
	

### Setup Client
- Connect EFLOW VM via Windows Admin Center or Powershell.
- Run socat in client mode: from the WAC CLI or Powershell window, type `sudo socat pty,link=/dev/ttyVirtS0,raw,user=iotedge-user,group=dialout,mode=777 tcp:172.18.246.137:5002`.  The command create a virtual serial port (**/dev/ttyVirtS0**) and relay data between the virtual serial port and server (ip address **172.18.246.137**, port **5002**)

### Verify connection
After the setup complete, you can verify the connection by sending data to the virtual serial port on the client and see if the data is received on the server.  The command window running hub4com will show messages when data received from or sent to the physical serial port.

### Start the connection when system boot up
You can further configure your host to enable the serial over network server when system boot up if necessary.

- Host: create a scheduled task to run hub4com.  The power shell script [scheduled-task-helper.ps1](./scheduled-task-helper.ps1) provides the following functions:
    1. `Add-StartupScheduledTask`: takes parameters TaskName, Execute and Argument to create a sheduled task that runs when system starts.
    2. `Remove-StartupScheduledTask`: task a parameter TaskName to unregister and delete the scheduled task with TaskName.

    To use the scripts,
    1. Save the scripts file to your PC.
    2. Open an elevated powershell window and change to the directory where you download the script.
    3. In the powershell window, import functions by dot sourcing the script.
    ```
    PS C:\Users\test> . .\scheduled-task-helper.ps1
    ```
    4. After importing the script, run the command Add-StartupScheduledTask with arguments
    ```
    PS C:\Users\test> Add-StartupScheduledTask -TaskName com2tcp -Execute 'C:\hub4com\com2tcp.bat' -Argument '\\.\COM3 5002'
    ```
    5. Check if the task created successfully and is running.  It might take a couple of seconds for task scheduler to start the task so you might see the task in Ready state.  Wait for a couple of seconds and re-run Get-ScheduledTask to get the latest task state.
    ```
    PS C:\Users\test> Get-ScheduledTask -TaskName com2tcp

    TaskPath                                       TaskName                          State
    --------                                       --------                          -----
    \                                              com2tcp                           Running
    ```
    
    6. Note: to clean up the scheduled task, run the Remove-StartupScheduledTask command.  You might need to reboot the system to ensure clean up the scheduled task
    ```
    PS C:\Users\test> Remove-StartupScheduledTask -TaskName com2tcp
    ```

- Client: configure socat to run as a service and auto-start at startup
    - Create a SysV init script [$home/socat](#socat-init-script) for running socat as a daemon
    - Create a socat config file [$home/socat.conf](#socat-config-file)
    - Place socat init script to /etc/init.d and start the socat service
```
    sudo cp $home/socat /etc/init.d/
    chmod +x /etc/init.d/socat
    sudo update-rc.d socat defaults
    
    sudo cp $/home/socat.conf /etc/default/
    sudo service socat restart
```


## Troubleshooting
-  Cannot connect to host
    * Make sure the firewall is setup correctly on the host to allow access to the port assigned to the server.
    * On the client, consider run socat with arguments `-d -d -d` to print fatal, error, warning notice, and info messages.

## Appendix
### socat init script

```
#! /bin/sh
### BEGIN INIT INFO
# Provides:          socat 
# Required-Start:    $local_fs $time $network $named
# Required-Stop:     $local_fs $time $network $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start/stop (socat a multipurpose relay)
#
# Description: The socat init script will start/stop socat as specified in /etc/default/socat 
#              Then log (FATAL,ERROR,WARN,INFO and Notic) in /var/log/socat.log
### END INIT INFO

NAME=socat
DAEMON=/usr/bin/socat
SOCAT_DEFAULTS='-d -d -d -lf /var/log/socat.log'

. /lib/lsb/init-functions
. /etc/default/socat.conf

PATH=/bin:/usr/bin:/sbin:/usr/sbin

[ -x $DAEMON ] || exit 0

start_socat() {
        start-stop-daemon --oknodo --quiet --start \
                --pidfile /var/run/socat.pid \
                --background --make-pidfile \
                --exec $DAEMON -- $SOCAT_DEFAULTS $OPTIONS < /dev/null
}

stop_socat() {
        start-stop-daemon --oknodo --stop --quiet --pidfile /var/run/socat.pid --exec $DAEMON
        rm -f /var/run/socat.pid
}

start () {
        start_socat
        return $?
}

stop () {
        for PIDFILE in `ls /var/run/socat.pid 2> /dev/null`; do
                NAME=`echo $PIDFILE | cut -c16-`
                NAME=${NAME%%.pid}
                stop_socat
        done
}

case "$1" in
    start)
	    log_daemon_msg "Starting multipurpose relay" "socat" 
	    if start ; then
		    log_end_msg $?
	    else
		    log_end_msg $?
	    fi
	    ;;
    stop)
	    log_daemon_msg "Stopping multipurpose relay" "socat"
            if stop ; then
                   log_end_msg $?
	   else
		   log_end_msg $?
	   fi
	   ;;
    restart)
	    log_daemon_msg "Restarting multipurpose relay" "socat"
            stop
            if start ; then
		    log_end_msg $?
	    else
		    log_end_msg $?
	    fi
	    ;;
    reload|force-reload)
	    log_daemon_msg "Reloading multipurpose relay" "socat"
	    stop
	    if start ; then
		    log_end_msg $?
	    else
		    log_end_msg $?
	    fi
	    ;;
    status)
            status_of_proc -p /var/run/socat.pid /usr/bin/socat socat && exit 0 || exit $?
	    ;;
    *)
        echo "Usage: /etc/init.d/$NAME {start|stop|restart|reload|force-reload|status}"
        exit 3
        ;;
esac

exit 0

```

### socat config file
```
OPTIONS="pty,link=/dev/ttyVirtS0,raw,user=iotedge-user,group=dialout,mode=777 tcp:172.18.246.137:5002"
```
