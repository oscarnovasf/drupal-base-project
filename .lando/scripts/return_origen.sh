#!/usr/bin/env bash

# ##############################################################################
#
# Este script cumple la finalidad de restablecer el proyecto a su estado inicial
# para poder volver a instalarlo.
#
# Notas:
# - Se trata de un script de desarrollo del proyecto "drupal-base-project".
# - No debe usarse con otros proyectos ya que se perdería toda la información.
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
DRUPAL_SETTINGS="sites/default/settings.php"


# ##############################################################################
# FUNCIONES AUXILIARES.
# ##############################################################################

# Simplemente imprime una línea por pantalla.
function linea() {
  echo '--------------------------------------------------------------------------------'
}

# Elimina los directorios especificados.
function eliminar_directorios() {
  local directorios=(
    "/app/drush/Commands/contrib"
    "/app/config/db"
    "/app/config/sync"
    "/app/config/translations"
    "/app/private_files"
    "/app/recipes"
    "/app/testing/simpletest"
    "/app/tmp"
    "/app/vendor"
    "/app/web/core"
    "/app/web/libraries"
    "/app/web/modules/contrib"
    "/app/web/profiles"
    "/app/web/sites/default/files"
    "/app/web/themes/contrib"
  )

  for dir in "${directorios[@]}"; do
    if [ -d "$dir" ]; then
      echo -e " - Eliminando ${YELLOW}'$dir'${RESET}..."
      rm -rf "$dir"
    else
      echo -e " - ${RED}Directorio no encontrado: '$dir'${RESET}"
    fi
  done
}

# Elimina los archivos especificados.
function eliminar_archivos() {
  local archivos=(
    "/app/composer.lock"
    "/app/.git/hooks/commit-msg"
    "/app/.git/hooks/pre-commit"
    "/app/web/.csslintrc"
    "/app/web/.eslintignore"
    "/app/web/.eslintrc.json"
    "/app/web/.ht.router.php"
    "/app/web/.htaccess"
    "/app/web/autoload.php"
    "/app/web/index.php"
    "/app/web/README.md"
    "/app/web/update.php"
    "/app/web/sites/default/settings.php"
  )

  for archivo in "${archivos[@]}"; do
    if [ -f "$archivo" ]; then
      chmod 777 "$archivo"
      echo -e " - Eliminando ${YELLOW}'$archivo'${RESET}..."
      rm -f "$archivo"
    else
      echo -e " - ${RED}Archivo no encontrado: '$archivo'${RESET}"
    fi
  done
}

# Elimina todos los archivos dentro de los directorios especificados, excepto .gitkeep.
function limpiar_directorios() {
  local directorios=(
    "/app/docs/data"
    "/app/docs/draw.io"
    "/app/docs/notes"
  )

  for dir in "${directorios[@]}"; do
    if [ -d "$dir" ]; then
      echo -e " - Limpiando ${YELLOW}'$dir'${RESET}..."
      find "$dir" -type f ! -name '.gitkeep' -exec rm -f {} +
    else
      echo -e " - ${RED}Directorio no encontrado: '$dir'${RESET}"
    fi
  done
}


# ##############################################################################
# INICIO DEL SCRIPT.
# ##############################################################################

clear
linea
echo -e " ${YELLOW}Iniciando el borrado de archivos.${RESET}"
linea

# Ajusto permisos para que no falle el reset.
chmod 777 /app/web/sites
chmod 777 /app/web/sites/default

eliminar_directorios
eliminar_archivos
limpiar_directorios


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