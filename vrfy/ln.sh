
if [ $# = '1' ]; then
ln -sv /var/lib
ln -sv /var/sbin
ln -sv /var/bin
ln -sv /var/data
fi

if [ $# = '0' ]; then
mkdir -p /var/lib
mkdir -p /var/sbin
mkdir -p /var/bin
mkdir -p /var/data
fi
