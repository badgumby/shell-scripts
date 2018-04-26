#!/bin/bash

itype="unknown"
function os_type
{
case `uname` in
  Linux )
     LINUX=1
     which yum && { itype="yum"; return; }
     which zypper && { itype="zypper"; return; }
     which apt-get && { itype="apt"; return; }
     ;;
  Darwin )
     DARWIN=1
     ;;
  * )
     # Handle AmgiaOS, CPM, and modified cable modems here.
     ;;
esac
}
os_type
echo $itype
