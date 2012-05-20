#!/bin/bash
# Замена для httpasswd, чтобы Apache не ставить =)
# Input params
fname=$1
realm=$2
user=$3
if [[ "$1" == "-c" ]]; then
    fname=$2
    realm=$3
    user=$4
    touch $fname
    chmod 640 $fname
else
    if [[ ! -r "$fname" ]]; then
	echo "Could not open passwd file $fname for reading."
	echo "Use -c option to create new one."
	exit 1
    fi
fi

# Entering password
#is_new_user=`cat $fname | cut -d\: -f1|grep ^$user$`
is_new_user=`cat $fname | grep "^$user\:$realm\:"`

if [[ "$is_new_user" == "" ]]; then
    echo "Adding password for $user in realm \"$realm\"."
else
    echo "Changing password for $user in realm \"$realm\"."
fi


read -s -p "New password: " pass
echo
read -s -p "Re-type new password: " pass_retry
echo
if [[ "$pass" != "$pass_retry" ]]; then
    echo "They don't match, sorry."
    pass=
    pass_retry=
    exit 1
fi
pass_retry=

hash=`echo -n "$user:$realm:$pass" | md5sum | cut -b -32`

# New user
if [[ "$is_new_user" == "" ]]; then
    echo $user:$realm:$hash >> $fname
    if [[ "$?" != "0" ]]; then
	echo "md5digest: Unable to update file $fname"
	echo "Use -c option to create new one."
    fi
    pass=

# Changing password
else
    sed -i "s/^$user:$realm:.*$/$user:$realm:$hash/" $fname
    if [[ "$?" != "0" ]]; then
	echo "md5digest: Unable to update file $fname"
	echo "Use -c option to create new one."
    fi
    pass=
fi

exit 0

