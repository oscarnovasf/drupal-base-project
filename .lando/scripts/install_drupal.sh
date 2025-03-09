#!/usr/bin/env bash

# ##############################################################################
#
# Script de instalación de Drupal vía Composer/Drush.
#
# - El script lee el entorno que se va a usar desde el archivo .env y activa o
#   no los módulos según el entorno.
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

# Rutas a los diferentes componentes / directorios.
DRUSH="/app/vendor/bin/drush"

# Cargo archivo con las variables de dependencias.
# source "$(dirname $0)"/.variables
source /app/scripts/shell/.variables

# Variables auxiliares.
HAS_DB="n"
SET_PRODUCTION="n"

# Exportación de configuraciones para composer.
export COMPOSER_ALLOW_SUPERUSER=1;
export COMPOSER_MEMORY_LIMIT=-1;
export COMPOSER_PROCESS_TIMEOUT=600


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

  if [[ "$DRUPAL_ENV" == "pro" || "$DRUPAL_ENV" == "stg" ]]; then
    SET_PRODUCTION="y"
  fi
}

# Verifica si existe una instalación previa.
function check_installed() {
  DIR_VENDOR=/app/vendor
  if [ -d "$DIR_VENDOR" ]; then
    clear
    linea
    echo -e " ${RED}El sistema ya está instalado, no se puede ejecutar este script.${RESET}"
    linea
    exit 2
  fi
}

# Verifica que existe realmente una configuración de Drupal.
function check_drupal() {
  WEB_ROOT="$(pwd)"
  if [ -f web/sites/default/default.settings.php ]; then
    WEB_ROOT="web"
  elif [ -f sites/default/default.settings.php ]; then
    WEB_ROOT="."
  else
    clear
    linea
    echo -e " ${RED}Este script debe ser ejecutado en la raíz del proyecto.${RESET}"
    echo "($WEB_ROOT)"
    linea
    exit 3
  fi
}

# Verifica si existe un volcado de la BBDD.
function check_db_dump() {
  if [ -f ./config/db/data.sql ]; then
    HAS_DB="y"
  fi
}

# Cambia los permisos de los archivos.
function asign_perms() {
  clear
  linea
  echo -e " ${YELLOW}Asignando permisos a ficheros...${RESET}"
  linea

  # Asigno grupo y propietario a todos los ficheros.
  find . \
    -path ./.git -prune \
    -o -exec chown "$USER_OWNER":"$USER_GROUP" {} + | pv -pte
}

# Función que finaliza la ejecución de la instalación.
function finalize() {
  # CAMBIO DE PERMISOS.
  asign_perms

  # FIN DEL SCRIPT.
  clear
  linea
  echo -e " ${YELLOW}Finalizando la instalación...${RESET}"
  linea

  # Ejecuto actualización de la base de datos.
  ${DRUSH} updatedb -y

  # Vuelvo a comprobar traducciones disponibles.
  ${DRUSH} locale-update

  # Limpio la caché.
  ${DRUSH} cache-rebuild

  # Calculo el tiempo de ejecución y muestro mensaje de final del script.
  end=$(date +%s)
  runtime=$((end-start))

  clear
  linea
  echo -e " ${YELLOW}Drupal instalado correctamente.${RESET}"
  if [ "$HAS_DB" == "y" ]; then
    echo -e " ${YELLOW}Es recomendable ejecutar un deploy tras esta instalación.${RESET}"
  fi
  echo " "
  echo -e " ${YELLOW}Tiempo de ejecución: ${runtime}s${RESET}"
  linea
  echo " "

  read -n 1 -s -r -p "Pulsa cualquier tecla para continuar..."
  exit 0
}

# Instala las dependencias del proyecto.
function run_composer() {
  echo " "
  linea
  echo -e " ${YELLOW}Instalando dependencias...${RESET}"
  linea

  if [ "$SET_PRODUCTION" == "y" ]; then
    composer install --no-dev
    # Realizo update por culpa de las dependencias de merge-plugin
    composer update --no-dev
  else
    composer install
    # Realizo update por culpa de las dependencias de merge-plugin
    composer update
  fi
}

# Realiza la instalación de Drupal.
function install_drupal() {
  clear
  linea
  echo -e " ${YELLOW}Instalando Drupal...${RESET}"
  linea

  # Ejecuto la instalación del sitio
  ${DRUSH} si -y
}

# Activa los módulos de Sandbox.
function activate_sandbox_modules() {
  clear
  linea
  echo -e " ${YELLOW}Activando módulos (SandBox)...${RESET}"
  linea

  # Módulos generales.
  for i in "${PROD_DRUSH_NAMES_SANDBOX[@]}"; do
    echo " "
    echo -e " ${GREEN}Activando ${i}...${RESET}"
    linea
    echo " "
    ${DRUSH} -y en "${i}"
  done
}

# Activa los módulos instalados.
function activate_modules() {
  clear
  linea
  echo -e " ${YELLOW}Activando módulos...${RESET}"
  linea

  # Módulos generales.
  for i in "${PROD_DRUSH_NAMES[@]}"; do
    echo " "
    echo -e " ${GREEN}Activando ${i}...${RESET}"
    linea
    echo " "
    ${DRUSH} -y en "${i}"
  done
}

# Activa los módulos de desarrollo si procede.
function activate_devel_modules() {
  if [ "$SET_PRODUCTION" == "n" ]; then
    clear
    linea
    echo -e " ${YELLOW}Activando módulos de desarrollo...${RESET}"
    linea

    for i in "${DEV_DRUSH_NAMES[@]}"; do
      echo " "
      echo -e " ${GREEN}Activando ${i}...${RESET}"
      linea
      echo " "
      ${DRUSH} -y en "${i}"
    done
  fi
}

# Crea el usuario manager y le asigna sus permisos.
function create_manager() {
  clear
  linea
  echo -e " ${YELLOW}Creando usuario Manager y asignando permisos...${RESET}"
  linea

  # Creo el usuario manager, el rol manager y lo asigno al usuario.
  ${DRUSH} user-create manager --mail="manager@example.com" --password="password"
  ${DRUSH} role:create manager Manager
  ${DRUSH} user-add-role manager manager

  # Asigno permisos por defecto al usuario manager.
  for i in "${MANAGER_PERMISSIONS[@]}"; do
    echo " "
    echo -e " ${GREEN}Asignando permiso: ${i}...${RESET}"
    linea
    echo " "
    ${DRUSH} role-add-perm "manager" "${i}"
  done
}

# Desactiva módulos y vistas que no uso.
function clear_drupal() {
  clear
  linea
  echo -e " ${YELLOW}Desactivando módulos y vistas innecesarias...${RESET}"
  linea

  # Desactivo vistas que no se usan normalmente.
  ${DRUSH} views:disable comments_recent
  ${DRUSH} views:disable content_recent
  ${DRUSH} views:disable who_s_new
  ${DRUSH} views:disable who_s_online

  # Elimino contenidos para poder desactivar el módulo.
  ${DRUSH} entity:delete shortcut -y

  # Desactivo módulos que no se usan normalmente.
  for i in "${CORE_MODULES_DISABLED[@]}"; do
    echo " "
    echo -e " ${GREEN}Desactivando ${i}...${RESET}"
    linea
    echo " "
    ${DRUSH} -y pm:uninstall "${i}"
  done
}

# Importa las configuraciones base.
function import_config() {
  clear
  linea
  echo -e " ${YELLOW}Importando configuraciones iniciales...${RESET}"
  linea

  # Realizo importaciones de configuraciones (Drupal).
  echo ' '
  ${DRUSH} config-import --partial --source="$(pwd)"/config/base/config_files/drupal/ -y

  # Realizo importaciones de configuraciones (Módulos).
  echo ' '
  ${DRUSH} config-import --partial --source="$(pwd)"/config/base/config_files/modulos/ -y

  # Realizo importaciones de configuraciones (Vistas).
  echo ' '
  ${DRUSH} config-import --partial --source="$(pwd)"/config/base/config_files/vistas/ -y
}

# Importa las configuraciones base.
function import_config_devel() {
  clear
    linea
    echo -e " ${YELLOW}Importando configuraciones iniciales (develop)...${RESET}"
    linea

    echo ' '
    ${DRUSH} config-import --partial --source="$(pwd)"/config/base/config_files/develop/ -y
}

# Realiza un volcado de la base de datos.
function dump_bbdd() {
  clear
  linea
  echo -e " ${YELLOW}Realizando copia de seguridad de la BBDD...${RESET}"
  linea

  # Vacio logs y caché de la base de datos.
  echo " "
  echo -e " - ${YELLOW}Vaciando watchdog y caché de Drupal...${RESET}"
  linea

  echo " "
  ${DRUSH} watchdog:delete all -y
  echo " "
  ${DRUSH} cr

  # Genero dump de la base de datos.
  echo " "
  echo -e " - ${YELLOW}Realizando volcado...${RESET}"
  linea

  echo " "
  ${DRUSH} sql-dump --result-file=../config/db/data.sql --skip-tables-key=common
}


# ##############################################################################
# COMPROBACIONES PREVIAS.
# ##############################################################################

clear

# Muestro cabecera del script.
linea
echo -e " ${GREEN}Script que permite la instalación de Drupal de una manera rápida.${RESET}"
echo -e " ${GREEN}(instala los módulos que solemos usar de manera habitual)${RESET}"
linea

echo " "
linea
echo -e " ${YELLOW}Ejecutando comprobaciones previas...${RESET}"
linea

load_env

check_installed
check_drupal
check_db_dump


# ##############################################################################
# INICIO DE LA INSTALACIÓN.
# ##############################################################################

clear

# Existe un volcado de la base de datos.
if [ "$HAS_DB" == "y" ]; then
  # Ejecuto instalación de composer.
  echo " "
  linea
  echo -e " ${YELLOW}Instalando dependencias...${RESET}"
  linea

  # Ejecuto el comando en lugar de la función run_composer porque en este caso
  # es mejor que se instalen todas las dependencias porque no sabemos como se ha
  # generado el volcado de la base de datos.
  composer install

  # Realizo la importación de la base de datos.
  clear
  linea
  echo -e " ${YELLOW}Realizando volcado de la base de datos...${RESET}"
  linea
  pv ./config/db/data.sql | ${DRUSH} sql-cli
else
  # Instalo las dependencias según el tipo de entorno.
  run_composer

  # Realizo la instalación de Drupal.
  install_drupal

  # Activo módulos.
  # activate_sandbox_modules
  # activate_modules

  # Creo usuario manager.
  create_manager

  # Elimino cosas innecesarias de Drupal.
  clear_drupal

  # Importo las configuraciones base.
  # import_config

  # Realizo backup de la BBDD antes de activar los módulos de desarrollo.
  dump_bbdd

  # Activo módulos de desarrollo.
  activate_devel_modules
  # import_config_devel
fi


# ##############################################################################
# FIN DE LA INSTALACIÓN.
# ##############################################################################

# Finalizo el script.
finalize
