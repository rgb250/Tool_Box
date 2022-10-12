# To Know if am I in a stable version or not:
lsb_release -a  # if there is written '(development branch)', I am not in a stable version

# To update 'kept-back' packages 
sudo apt-get --with-new-pkgs

# To know what process holds a given file for exapmple '/var/cache/debconf/config.dat': 
sudo lsof /var/cache/debconf/config.dat
