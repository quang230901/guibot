#!/bin/bash
set -e

# rpm dependencies
dnf -y install python3 python3-coverage
# python-imaging
dnf -y install python3-pillow
# contour, template, feature, cascade, text matching
dnf -y install python3-numpy python3-opencv
# text matching
dnf -y install tesseract
# desktop control
dnf -y install xdotool xwd ImageMagick
dnf -y install vnc-server

# pip dependencies (not available as RPM)
dnf -y install gcc libX11-devel libXtst-devel python3-devel libpng-devel redhat-rpm-config
pip3 install autopy==1.0.1
pip3 install torch==0.4.0 torchvision==0.2.1
pip3 install vncdotool==0.12.0

# rpm packaging
dnf -y install rpm-build
ROOT=""
NAME=$(sed -n 's/^Name:[ \t]*//p' "$ROOT/guibot/packaging/guibot.spec")
VERSION=$(sed -n 's/^Version:[ \t]*//p' "$ROOT/guibot/packaging/guibot.spec")
cp -r "$ROOT/guibot" "$ROOT/$NAME-$VERSION"
mkdir -p ~/rpmbuild/SOURCES
tar czvf ~/rpmbuild/SOURCES/$NAME-$VERSION.tar.gz -C "$ROOT/" --exclude=.* $NAME-$VERSION
rpmbuild -ba "$ROOT/$NAME-$VERSION/packaging/guibot.spec" --with opencv
cp ~/rpmbuild/RPMS/x86_64/$NAME-$VERSION*.rpm "$ROOT/guibot"
dnf -y install "$ROOT/guibot/"$NAME-$VERSION*.rpm
rm -fr "$ROOT/$NAME-$VERSION"

# virtual display
dnf install -y xorg-x11-server-Xvfb
export DISPLAY=:99.0
Xvfb :99 -screen 0 1024x768x24 &> /tmp/xvfb.log  &
sleep 3  # give xvfb some time to start

# unit tests
dnf install -y python3-PyQt5
cd /lib/python3.6/site-packages/guibot/tests
LIBPATH=".." COVERAGE="python3-coverage" sh run_tests.sh

exit 0
