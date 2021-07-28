#!/bin/sh

SUITE=$1
NONFREE=$2

if [ "$SUITE" = "bullseye" ]; then
    COMPONENTS="main"
    [ "$NONFREE" = "true" ] && COMPONENTS="$COMPONENTS non-free"
    echo "deb http://security.debian.org/debian-security $SUITE-security $COMPONENTS" >> /etc/apt/sources.list
fi

# Set the proper suite in our sources.list
sed -i "s/@@SUITE@@/${SUITE}/" /etc/apt/sources.list.d/mobian.list

# Setup repo priorities so mobian comes first
cat > /etc/apt/preferences.d/00-mobian-priority << EOF
Package: *
Pin: release o=Mobian
Pin-Priority: 700

Package: *
Pin: release o=Debian
Pin-Priority: 500
EOF
