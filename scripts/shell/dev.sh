#!/usr/bin/env bash

# ##############################################################################
#
# Script de activación / desactivación de opciones de desarrollo.
#
# - Recibe como parámetro la palabra on|off:
#   * on implica la activación de las opciones de desarrollo.
#   * off implica la desactivación de las opciones de desarrollo.
# - En caso de no indicar parámetro se toma el valor establecido en .env.
#
#  @version   v1.0.0
#  @license   GNU/GPL v3+
# ##############################################################################


# Control de tiempo de ejecución.
start=$(date +%s)

# Cierro el script en caso de error.
set -e


# ##############################################################################
# VARIABLES AUXILIARES.
# ##############################################################################

# Colores.
RESET="\033[0m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
GREEN="\033[0;32m"

# Cargo archivo con las variables de dependencias.
source "$(dirname $0)"/.variables

# Rutas a los diferentes componentes / directorios.
DRUSH_DIR="vendor/bin/drush"
DRUSH="./vendor/bin/drush"


# ##############################################################################
# FUNCIONES AUXILIARES.
# ##############################################################################

# Simplemente imprime una línea por pantalla.
function linea() {
  echo '--------------------------------------------------------------------------------'
}

# Lee archivo de configuración.
function load_env() {
  ENV_FILE=.env
  if [ ! -f "${ENV_FILE}" ]; then
    clear
    linea
    echo -e " ${RED}No existe el archivo de variables de entorno (.env).${RESET}"
    linea
    exit 1
  else
    source "$(echo ${ENV_FILE})"
  fi
}

# Verifica que existe realmente una configuración de Drupal.
function check_drupal() {
  WEB_ROOT="$(pwd)"
  if [ -f web/sites/default/default.settings.php ]; then
    WEB_ROOT="web"
  else
    clear
    linea
    echo -e " ${RED}Este script debe ser ejecutado en la raíz del proyecto.${RESET}"
    echo "($WEB_ROOT)"
    linea
    exit 3
  fi
}

# Verifica que las herramientas necesarias están instaladas en el servidor.
function check_requirements() {
  # Verifico instalación de Drush.
  if [ ! -f "${DRUSH_DIR}" ]; then
    clear
    linea
    echo -e " ${RED}No se encuentra $DRUSH_DIR.${RESET}"
    echo -e " ${RED}Ejecuta: composer require drush/drush${RESET}"
    linea
    exit 2
  fi
}

# Cambia la variable de entorno DRUPAL_ENV.
function change_env() {
  local ENVIRONMENT=$1

  if [[ "$ENVIRONMENT" =~ ^(loc|dev|stg|pro)$ ]]; then
    echo " "
    echo -e " ${YELLOW}Estableciendo entorno a '${ENVIRONMENT}'...${RESET}"
    linea

    sed -i "s/^CONFIG_SPLIT_ENV=.*/CONFIG_SPLIT_ENV=${ENVIRONMENT}/" "${ENV_FILE}"
  else
    echo " "
    echo -e " ${RED}Error: El entorno '${ENVIRONMENT}' no es válido. Usa loc, dev, stg o pro.${RESET}"
    linea
    exit 1
  fi
}


# ##############################################################################
# COMPROBACIONES PREVIAS.
# ##############################################################################

# Número de parámetros
if [ ! "$#" -eq 1 ]; then
  clear
  usage
  exit 1
fi

# Compruebo que exista el archivo de variables de entorno.
load_env

# Verifico que Drupal se encuentra en una de las rutas válidas.
check_drupal

# Verifico existencia de herramientas necesarias.
check_requirements

# Exportación de configuraciones para composer.
export COMPOSER_ALLOW_SUPERUSER=1;
export COMPOSER_MEMORY_LIMIT=-1;
export COMPOSER_PROCESS_TIMEOUT=600
-

# ##############################################################################
# INICIO DEL SCRIPT.
# ##############################################################################

clear

# Compruebo el entorno pasado como parámetro.
ENVIRONMENT=$1

case "$ENVIRONMENT" in
  loc|dev)
    # Pongo el Drupal en modo mantenimiento.
    ${DRUSH} sset system.maintenance_mode TRUE
    echo " "
    echo -e " ${YELLOW}Estableciendo entorno a '${ENVIRONMENT}'...${RESET}"
    linea
    change_env "$ENVIRONMENT"

    echo " "
    echo -e " ${YELLOW}Actualizando dependencias de desarrollo...${RESET}"
    linea
    composer install

    echo " "
    echo -e " ${YELLOW}Activando módulos de desarrollo...${RESET}"
    linea
    for i in "${DEV_DRUSH_NAMES[@]}"; do
      echo " "
      echo -e " Activando ${GREEN}${i}${RESET}..."
      ${DRUSH} -y en "${i}"
    done

    echo -e " ${YELLOW}Importando configuraciones de desarrollo...${RESET}"
    linea
    ${DRUSH} config-import --partial --source=$(pwd)/config/base/modules/devel/ -y
    ;;

  stg|pro)
    # Pongo el Drupal en modo mantenimiento.
    ${DRUSH} sset system.maintenance_mode TRUE
    echo " "
    echo -e " ${YELLOW}Estableciendo entorno a '${ENVIRONMENT}'...${RESET}"
    linea
    change_env "$ENVIRONMENT"

    echo -e " ${YELLOW}Desactivando módulos...${RESET}"
    linea
    for i in "${DEV_DRUSH_NAMES_UNINSTALL[@]}"; do
      echo " "
      echo -e " Desinstalando ${GREEN}${i}${RESET}..."
      ${DRUSH} -y pm:uninstall "${i}"
    done
    ${DRUSH} cache-rebuild

    echo -e " ${YELLOW}Eliminando módulos...${RESET}"
    linea
    composer install --no-dev
    ;;

  *)
    # Desactivo modo de mantenimiento.
    ${DRUSH} sset system.maintenance_mode FALSE
    echo " "
    echo -e " ${RED}Error: El entorno '${ENVIRONMENT}' no es válido. Usa loc, dev, stg o pro.${RESET}"
    linea
    exit 1
    ;;
esac

# Desactivo modo de mantenimiento.
${DRUSH} sset system.maintenance_mode FALSE


# ##############################################################################
# FIN DEL SCRIPT.
# ##############################################################################

clear
linea
echo -e " ${YELLOW}Finalizando la instalación...${RESET}"
linea
echo " "

# Ejecuto tareas de deploy.
${DRUSH} custom:deploy

# Calculo el tiempo de ejecución y muestro mensaje de final del script.
end=$(date +%s)
runtime=$((end-start))

clear
linea
echo -e " ${GREEN}Cambio realizado correctamente.${RESET}"
linea
echo " "
echo " Tiempo de ejecución: ${runtime}s"
echo " "
