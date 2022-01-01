#!/system/bin/sh

varPath=${0%/*}
source ${varPath}/var.sh

wait_until_login()
{
    # in case of /data encryption is disabled
    while [ "$(getprop sys.boot_completed)" != "1" ]; do
        sleep 1
    done

    # we doesn't have the permission to rw "/sdcard" before the user unlocks the screen
    local test_file="/sdcard/Pictures/.sdBind_TEST"
    touch "$test_file"
    while [ ! -f "$test_file" ]; do
        touch "$test_file"
        sleep 1
    done
    rm "$test_file"
}

#echo "preLogin" > /data/adb/00Sev/sdBind/preLogin.log
wait_until_login
#echo "Login" > /data/adb/00Sev/sdBind/Login.log
su -M -c sh ${WorkDir}/sdBind.sh #> /data/adb/00Sev/sdBind/start.log
#echo "Start" >> /data/adb/00Sev/sdBind/start.log
exit 0