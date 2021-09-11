#!/system/bin/sh

varPath=${0%/*}
source ${varPath}/var.sh

log "[i]" "[Start]" ""

mkBindRoot () {
	[ ! -d ${bindRoot} ]\
	&& mkdir -p ${bindRoot} && \
	log "[i]" "[Mkdir]" "${bindRoot}"

	[ -d ${bindRoot} ]\
	&& chown root:sdcard_rw ${bindRoot}
	[ ! -f ${bindRoot}/.nomedia ]\
	&& touch ${bindRoot}/.nomedia

	[ -f ${bindRoot}/.nomedia ]\
	&& chown root:sdcard_rw ${bindRoot}/.nomedia\
	&& chmod 0775 ${bindRoot}/.nomedia

	log "[i]" "[checked]" "${bindRoot}"
	for runtime in ${runtimeSheet[@]}
	do
		runtimeLs=${runtime}/${configDirName}
		[ ! -L ${runtimeLs} ]\
		&& ln -sf ${bindRoot} ${runtimeLs}\
		&& log "[i]" "[Link]" "${bindRoot} ——→ ${runtimeLs}"
	done
}

mountBindPoint () {
	[ ! -d ${bindPoint} ]\
	&& mkdir -p ${bindPoint}\
	&& log "[i]" "[Mkdir]" "${bindPoint}"

  [ -d ${bindPoint} ]\
  && chown root:sdcard_rw ${bindPoint}

  if ! mount | grep -q ${bindPoint}; then
		su -M -c bindfs -u root -g 1015 -p 0775 ${mountDevice} ${bindPoint}
		log "[i]" "[Mounted]" "${mountPoint} ——→ ${bindPoint}"
	fi
}

log "[i]" "[Done]" ""
exit