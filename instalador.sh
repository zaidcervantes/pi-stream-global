#!/bin/bash

# VARIABLES
USER_REMOTEIT="zcervantesa@gmail.com"
PASS_REMOTEIT="zaid2005"
DEVICE_NAME="Dron de frambuesa"
SERVICE_NAME="LiveStreamCam"
IP_ADDRESS="192.168.1.100"
RESOLUTION="640x480"
FPS="30"
ACCESS_FILE="acceso.txt"

# FUNCIONES
set_static_ip() {
  echo "Configurando IP fija..."
  sudo cp /etc/dhcpcd.conf /etc/dhcpcd.conf.backup
  echo -e "\ninterface wlan0\nstatic ip_address=${IP_ADDRESS}/24\nstatic routers=192.168.1.1\nstatic domain_name_servers=8.8.8.8 1.1.1.1" | sudo tee -a /etc/dhcpcd.conf
  sudo service dhcpcd restart
}

install_mjpg_streamer() {
  echo "Instalando MJPG-streamer..."
  sudo apt update && sudo apt install -y git cmake libjpeg8-dev imagemagick libv4l-dev
  git clone https://github.com/jacksonliam/mjpg-streamer.git
  cd mjpg-streamer/mjpg-streamer-experimental
  make
  sudo make install
}

start_streaming() {
  echo "Iniciando streaming..."
  ./mjpg_streamer -i "./input_uvc.so -r $RESOLUTION -f $FPS" -o "./output_http.so -p 8080 -w ./www" &
}

install_remoteit() {
  echo "Instalando Remote.it..."
  curl https://downloads.remote.it/remoteit/install_agent.sh | sudo bash
  remoteit agent install
  remoteit agent login "$USER_REMOTEIT" "$PASS_REMOTEIT"
  remoteit agent register --name "$DEVICE_NAME" --service "$SERVICE_NAME" --port 8080 --host "$IP_ADDRESS"
  echo "Acceso configurado para $DEVICE_NAME con Remote.it"
}

main() {
  set_static_ip
  install_mjpg_streamer
  start_streaming
  install_remoteit
  echo "Instalación completada exitosamente."
}

main
