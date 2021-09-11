#!/system/bin/sh

varPath=${0%/*}
source ${varPath}/var.sh

echo "WorkDir: ${WorkDir}"
#mkdir mountRoot
[ ! -d ${mountRoot} ]\
&& mkdir -p ${mountRoot}\
&& log "[i]" "[Mkdir]" "${mountRoot}"\
&& chown root:sdcard_rw ${mountRoot}\
&& touch ${mountRoot}/.nomedia\
&& chown root:sdcard_rw ${mountRoot}/.nomedia\
&& chmod 0775 ${mountRoot}/.nomedia
#mount mountPoint
[ -d ${mountPoint} ]\
&& mount -t ext4 -w ${mountDevice} ${mountPoint} >> ${logFile} 2>&1\
&& log "[i]" "[Mount]" "${mountPoint}"