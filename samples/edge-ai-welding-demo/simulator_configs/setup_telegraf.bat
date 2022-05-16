@ECHO OFF 
ECHO Downloading Telegraf...

powershell  wget https://dl.influxdata.com/telegraf/releases/telegraf-1.21.1_windows_amd64.zip -UseBasicParsing -OutFile telegraf_windows_amd64.zip

ECHO Setting up Telegraf...

powershell  Expand-Archive -f .\telegraf_windows_amd64.zip -DestinationPath 'C:\Program Files\InfluxData\telegraf\'

copy telegraf.conf "C:\Program Files\InfluxData\telegraf\"
copy  "C:\Program Files\InfluxData\telegraf\telegraf-1.21.1\telegraf.exe" "C:\Program Files\InfluxData\telegraf"

ECHO Setting Up Telegraf is completed.
ECHO Now run the configuration script and follow the document