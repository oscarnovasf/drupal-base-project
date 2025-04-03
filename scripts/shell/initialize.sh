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


# ##############################################################################
# FUNCIONES AUXILIARES.
# ##############################################################################

# Simplemente imprime una línea por pantalla.
function linea() {
  echo '--------------------------------------------------------------------------------'
}

# Función que imprime las instrucciones de uso.
usage() {
  echo " "
  linea
  echo -e " ${GREEN}Script de limpieza del proyecto.${RESET}"
  linea
  echo " "
  echo " Uso: ${SELF} [-y|--yes]"
  echo " "
  echo " [-y|--yes] Realiza la operación, si no se especifica simplemente"
  echo "            muestra los archivos que se borrarán."
  echo " "
}


# ##############################################################################
# INICIO DEL SCRIPT.
# ##############################################################################

clear

# Verifico los parámetros pasados al script.
SHOW_HELP=false
EXECUTE_CLEAN=false

for arg in "$@"; do
  case $arg in
    -h|--help)
      SHOW_HELP=true
      ;;
    -y|--yes)
      EXECUTE_CLEAN=true
      ;;
  esac
done

if [ "$SHOW_HELP" = true ]; then
  usage
  exit 0
elif [ "$EXECUTE_CLEAN" = true ]; then
  linea
  echo -e " ${GREEN}Iniciando el borrado de archivos.${RESET}"
  linea
  git config --global --add safe.directory /app
  git clean -fdx
else
  linea
  echo -e " ${GREEN}Estos serían los archivos a borrar:${RESET}"
  linea
  git config --global --add safe.directory /app
  git clean -fdxn
fi


# ##############################################################################
# FIN DEL SCRIPT.
# ##############################################################################

# Calculo el tiempo de ejecución y muestro mensaje de final del script.
end=$(date +%s)
runtime=$((end-start))

if [ "$EXECUTE_CLEAN" = true ]; then
  clear
  linea
  echo -e " ${GREEN}Proyecto reiniciado correctamente.${RESET}"
  linea
fi
echo " "
echo " Tiempo de ejecución: ${runtime}s"
echo " "