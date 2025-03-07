#!/usr/bin/env bash

# ##############################################################################
#
# Script que inicializa el proyecto para poder volver a instalarlo.
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

# Rutas de los archivos.
CONTRIB_MODULES_PATH="modules/contrib"
CONTRIB_THEMES_PATH="themes/contrib"
CONTRIB_PROFILES_PATH="profiles/contrib"
CONTRIB_DRUSH_PATH="drush/Commands/contrib"
DRUPAL_SETTINGS="sites/default/settings.php"
DRUPAL_CORE="core"
DRUPAL_LIBRARIES="libraries"


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


# ##############################################################################
# COMPROBACIONES PREVIAS.
# ##############################################################################

# Leo variables de entorno
load_env


# ##############################################################################
# INICIO DEL SCRIPT.
# ##############################################################################

clear
linea
echo -e " ${YELLOW}Iniciando el borrado de archivos.${RESET}"
linea

# Ajusto permisos para que no falle la nueva instalación.
chmod 777 ${WEB_ROOT}/sites
chmod 777 ${WEB_ROOT}/sites/default

# Elimino módulos contrib.
if [ -d "${WEB_ROOT}/${CONTRIB_MODULES_PATH}" ]; then
  echo -e " - Eliminando ${YELLOW}'${WEB_ROOT}/${CONTRIB_MODULES_PATH}'${RESET}..."
  rm -fr "${WEB_ROOT:?}/${CONTRIB_MODULES_PATH}"
fi

# Elimino plantillas contrib.
if [ -d "${WEB_ROOT}/${CONTRIB_THEMES_PATH}" ]; then
  echo -e " - Eliminando ${YELLOW}'${WEB_ROOT}/${CONTRIB_THEMES_PATH}'${RESET}..."
  rm -fr "${WEB_ROOT:?}/${CONTRIB_THEMES_PATH}"
fi

# Elimino profiles contrib.
if [ -d "${WEB_ROOT}/${CONTRIB_PROFILES_PATH}" ]; then
  echo -e " - Eliminando ${YELLOW}'${WEB_ROOT}/${CONTRIB_PROFILES_PATH}'${RESET}..."
  rm -fr "${WEB_ROOT:?}/${CONTRIB_PROFILES_PATH}"
fi

# Elimino drush commands contrib.
if [ -d "./${CONTRIB_DRUSH_PATH}" ]; then
  echo -e " - Eliminando ${YELLOW}'./${CONTRIB_DRUSH_PATH}'${RESET}..."
  rm -fr "./${CONTRIB_DRUSH_PATH}"
fi

# Elimino configuración.
if [ -d "${WEB_ROOT}/${DRUPAL_SETTINGS}" ]; then
  echo -e " - Eliminando ${YELLOW}'${WEB_ROOT}/${DRUPAL_SETTINGS}'${RESET}..."
  rm -fr "${WEB_ROOT:?}/${DRUPAL_SETTINGS}"
fi

# Elimino el core de Drupal.
if [ -d "${WEB_ROOT}/${DRUPAL_CORE}" ]; then
  echo -e " - Eliminando ${YELLOW}'${WEB_ROOT}/${DRUPAL_CORE}'${RESET}..."
  rm -fr "${WEB_ROOT:?}/${DRUPAL_CORE}"
fi

# Elimino libraries.
if [ -d "${WEB_ROOT}/${DRUPAL_LIBRARIES}" ]; then
  echo -e " - Eliminando ${YELLOW}'${WEB_ROOT}/${DRUPAL_LIBRARIES}'${RESET}..."
  rm -fr "${WEB_ROOT:?}/${DRUPAL_LIBRARIES}"
fi

# Elimino carpeta vendor.
if [ -d "vendor" ]; then
  echo -e " - Eliminando ${YELLOW}'./vendor'...${RESET}"
  rm -fr "vendor"
fi


# ##############################################################################
# FIN DEL SCRIPT.
# ##############################################################################

# Calculo el tiempo de ejecución y muestro mensaje de final del script.
end=$(date +%s)
runtime=$((end-start))

clear
linea
echo -e " ${GREEN}Proyecto reiniciado correctamente.${RESET}"
linea
echo " "
echo " Tiempo de ejecución: ${runtime}s"
echo " "