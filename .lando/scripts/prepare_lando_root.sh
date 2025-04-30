#!/usr/bin/env bash

# ##############################################################################
#
# Realiza la configuración inicial del contenedor para el proyecto.
# (configuraciones que son necesarias realizar con el usuario root)
#
#  @version   v1.1.0
#  @license   GNU/GPL v3+
# ##############################################################################


################################################################################
# CONFIGURACIÓN DEL SCRIPT.
################################################################################


# Cierro el script en caso de error.
set -e

# Colores.
RESET="\033[0m"
YELLOW="\033[0;33m"

# Control de tiempo de ejecución.
START=$(date +%s)


################################################################################
# FUNCIONES.
################################################################################


# Simplemente imprime una línea por pantalla.
function linea() {
  echo '--------------------------------------------------------------------------------'
}

# Muestra la cabecera de algunas respuestas del script.
function show_header() {
  linea
  echo -e " ${YELLOW}Preparando contenedor${RESET}"
  linea
}

# Mensaje de finalización del script.
function show_bye() {
  # Calculo el tiempo de ejecución y muestro mensaje de final del script.
  END=$(date +%s)
  RUNTIME=$((END-START))

  clear
  echo " "
  echo -e " Tiempo de ejecución: ${RUNTIME}s"
  linea
  exit 0
}

# Instalación de JQ.
function install_jq() {
  echo " "
  echo -e " Instalando ${YELLOW}JQ${RESET}..."
  linea

  apt-get update -y && apt-get install -y jq
}

# Instalación de PV.
function install_pv() {
  echo " "
  echo -e " Instalando ${YELLOW}PV${RESET}..."
  linea

  apt-get update -y && apt-get install -y pv
}

# Instalación de Cloc.
function install_cloc() {
  echo " "
  echo -e " Instalando ${YELLOW}Cloc${RESET}..."
  linea

  apt-get update -y && apt-get install -y cloc
}

# Instalación y activación de Node.js.
function install_node() {
  local NODE_MAJOR=$1

  # Verificar si el parámetro existe y es numérico
  if [[ -z "$NODE_MAJOR" || ! "$NODE_MAJOR" =~ ^[0-9]+$ ]]; then
    echo "Error: Se requiere un parámetro numérico para NODE_MAJOR."
    return 1
  fi

  echo " "
  echo -e " Instalando y activando ${YELLOW}Node.js ${NODE_MAJOR}.x${RESET}..."
  linea

  apt-get update
  apt-get install -y ca-certificates curl gnupg

  mkdir -p /etc/apt/keyrings
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

  apt-get update
  apt-get install nodejs -y

  chown -R www-data /usr/lib/node_modules
  chown -R www-data /usr/bin
  npm install --silent -g npm
}

# Instalación de GULP.
function install_gulp() {
  echo " "
  echo -e " Instalando ${YELLOW}Gulp${RESET}..."
  linea

  npm install -g gulp-cli
}

# Instalación de SASS.
function install_sass() {
  echo " "
  echo -e " Instalando ${YELLOW}SASS${RESET}..."
  linea

  npm install -g sass
}

# Instalación y activación de OCI8.
# Ver: https://github.com/lando/docs/issues/33
# Ver: https://pecl.php.net/package/oci8/3.2.0
function install_oci8_ubuntu() {
  echo " "
  echo -e " Instalando y activando ${YELLOW}oci8...${RESET}"
  linea

  mkdir /opt/oracle
  curl https://download.oracle.com/otn_software/linux/instantclient/217000/instantclient-basic-linux.x64-21.7.0.0.0dbru.zip > /opt/oracle/instantclient-basic.zip
  curl https://download.oracle.com/otn_software/linux/instantclient/217000/instantclient-sdk-linux.x64-21.7.0.0.0dbru.zip > /opt/oracle/instantclient-sdk.zip

  unzip /opt/oracle/instantclient-basic.zip -d /opt/oracle
  unzip /opt/oracle/instantclient-sdk.zip -d /opt/oracle

  rm /opt/oracle/instantclient-basic.zip
  rm /opt/oracle/instantclient-sdk.zip

  echo /opt/oracle/instantclient_21_7 > /etc/ld.so.conf.d/oracle-instantclient.conf
  ldconfig -v

  apt update
  apt install libaio1

  # Modificar la versión de oci8 en caso de ser necesario (pecl install oci8-x.x.x).
  echo "instantclient,/opt/oracle/instantclient_21_7" | pecl install oci8-3.2.1
  docker-php-ext-enable oci8
}

# Instalación y activación de OCI8.
# Ver: https://github.com/lando/docs/issues/33
# Ver: https://pecl.php.net/package/oci8/3.2.0
function install_oci8_mac() {
  echo " "
  echo -e " Instalando y activando ${YELLOW}oci8...${RESET}"
  linea

  mkdir /opt/oracle
  curl https://download.oracle.com/otn_software/linux/instantclient/191000/instantclient-basic-linux.arm64-19.10.0.0.0dbru-2.zip > /opt/oracle/instantclient-basic.zip
  curl https://download.oracle.com/otn_software/linux/instantclient/191000/instantclient-sdk-linux.arm64-19.10.0.0.0dbru.zip > /opt/oracle/instantclient-sdk.zip

  unzip /opt/oracle/instantclient-basic.zip -d /opt/oracle
  unzip /opt/oracle/instantclient-sdk.zip -d /opt/oracle

  rm /opt/oracle/instantclient-basic.zip
  rm /opt/oracle/instantclient-sdk.zip

  echo /opt/oracle/instantclient_19_10 > /etc/ld.so.conf.d/oracle-instantclient.conf
  ldconfig -v

  apt update
  apt install libaio1

  # Modificar la versión de oci8 en caso de ser necesario (pecl install oci8-x.x.x).
  echo "instantclient,/opt/oracle/instantclient_19_10" | pecl install oci8-3.2.1
  docker-php-ext-enable oci8
}

# Instalación de bromas/chistes.
function install_jokes() {
  echo " "
  echo -e " Instalando ${YELLOW}bromas/chistes${RESET}..."
  linea

  apt-get update -y && apt-get install -y \
    sysvbanner \
    figlet \
    cowsay \
    fortune \
    fortunes \
    fortunes-es \
    fortunes-es-off
}


################################################################################
# CUERPO PRINCIPAL DEL SCRIPT.
################################################################################


show_header

# Herramientas de sistema.
install_jq
install_pv
install_cloc

# Herramientas de desarrollo.
install_node 20
install_gulp
install_sass

# Herramientas de conexión con BBDD.
# install_oci8_ubuntu
# install_oci8_mac

# Un poco de humor.
install_jokes

show_bye
