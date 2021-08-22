#!/bin/sh
#
# Systemback Debian packages installer script.
#
# Compatible with Ubuntu 14.04.X LTS,
#                 Ubuntu 15.04,
#                 Ubuntu 15.10,
#                 Ubuntu 16.04.X LTS,
#                 Debian 8.0
#
# This script can be used and modified freely, without any restrictions.
#
# Last modification: 2016.02.14. by Krisztián Kende <nemh@freemail.hu>

[ $(id -ur) = 0 ] || {
  tput bold
  tput setaf 1

  cat << EOF

 Root privileges are required for running Systemback installer!

EOF

  tput sgr0
  exit 1
}

case "$(lsb_release -cs)" in
  trusty)
    release=Ubuntu_Trusty
    ;;
  vivid)
    release=Ubuntu_Vivid
    ;;
  wily)
    release=Ubuntu_Wily
    ;;
  xenial)
    release=Ubuntu_Xenial
    ;;
  jessie)
    release=Debian_Jessie
    ;;
  *)
    tput bold
    tput setaf 1

    cat << EOF

 Your system is not compatible with this Systemback Install Pack!

EOF

    tput sgr0
    tput bold

    cat << EOF
 Press 'A' to abort the installation, or select one of the following releases:

  1 ─ Ubuntu 14.04.X LTS (Trusty Tahr)
  2 ─ Ubuntu 15.04 (Vivid Vervet)
  3 ─ Ubuntu 15.10 (Wily Werewolf)
  4 ─ Ubuntu 16.04.X LTS (Xenial Xerus)
  5 ─ Debian 8.0 (Jessie)
EOF

    tput civis
    tput invis
    [ ! "$release" ] || release=""

    until [ "$release" ]
    do
      read -n 1 input 2>/dev/null || input=$(bash -c 'read -n 1 i ; printf $i')

      case $input in
        [aA])
          break
          ;;
        1)
          release=Ubuntu_Trusty
          ;;
        2)
          release=Ubuntu_Vivid
          ;;
        3)
          release=Ubuntu_Wily
          ;;
        4)
          release=Ubuntu_Xenial
          ;;
        5)
          release=Debian_Jessie
      esac
    done

    tput cnorm
    tput sgr0
    echo
    [ "$release" ] || exit
esac

parch=$(getconf LONG_BIT)
dpath="$(printf "$0" | head -c -10)"packages/

if [ $(expr length "$dpath") -le 11 ]
then ver=$(pwd | tail -c 8)
else ver=$(printf "$dpath" | tail -c 17 | head -c 7)
fi

[ "$1" = -d ] || (dpkg -l | grep -E "^ii +l?i?b?systemback" | grep "\-dbg" >/dev/null && apt-get remove --purge -y --force-yes systemback-dbg* systemback-cli-dbg systemback-scheduler-dbg)

if [ $parch = 64 ]
then
  pkgs="'$dpath'"*.deb

  for a in "$dpath"$release/*amd64.deb
  do printf "$a" | grep "\-dbg" >/dev/null || pkgs="$pkgs '$a'"
  done
else
  pkgs="'$dpath'"*locales*.deb

  for a in "$dpath"$release/*i386.deb
  do printf "$a" | grep "\-dbg" >/dev/null || pkgs="$pkgs '$a'"
  done
fi

sh -c "dpkg -i $pkgs"
[ $? = 0 ] || apt-get install -fym --force-yes

[ $? = 0 ] && {
  if [ "$1" = -d ]
  then
    if [ $parch = 64 ]
    then
      cnt=10
      dpkg -i "$dpath"$release/*dbg*amd64.deb
    else
      cnt=9
      dpkg -i "$dpath"$release/*dbg*i386.deb
    fi
  elif [ $parch = 64 ]
  then cnt=6
  else cnt=5
  fi
}

if [ $? = 0 ] && [ $(dpkg -l | grep -E "^ii +l?i?b?systemback" | grep -c " $ver ") = $cnt ]
then
  tput bold

  cat << EOF

 Systemback installation is successful.

EOF

  tput sgr0
else
  tput bold
  tput setaf 1

  cat << EOF

 Systemback installation is failed!

EOF

  tput sgr0
  exit 2
fi
