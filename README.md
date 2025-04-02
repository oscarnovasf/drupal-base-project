Drupal: Base Project
===

Plantilla para [Composer](https://getcomposer.org/) de instalación de Drupal.

[![version][version-badge]][changelog] [![Licencia][license-badge]][license] [![Código de conducta][conduct-badge]][conduct]  
[![wakatime](https://wakatime.com/badge/user/236d57da-61e8-46f2-980b-7af630b18f42/project/f988ef5a-1e85-4d32-9121-75c552c747ec.svg)](https://wakatime.com/badge/user/236d57da-61e8-46f2-980b-7af630b18f42/project/f988ef5a-1e85-4d32-9121-75c552c747ec)

## Requerimientos

* ### Herramientas para desarrollo en máquina Local.
  * El proyecto está pensado para usar [Lando](https://lando.dev/) como entorno
    de desarrollo local.
  * Si se quiere poder enviar una url de nuestro proyecto en local con [Lando](https://lando.dev/),
    es necesario instalar y configurar [NGROK](https://ngrok.com/).

* ### Herramientas para servidores (dev, stg o pro)
  * Es necesario tener instalada la herramienta [JQ](https://stedolan.github.io/jq/)
    para la línea de comandos.
  * Es necesario tener instalada la herramienta [PV](http://www.ivarch.com/programs/pv.shtml)
    para la línea de comandos.

* ### Otros Requerimientos
  * El proyecto está pensado para hacer uso de *Redis* / *KeyDB*, por lo que
    será necesario tener acceso a una de estas herramientas.
    Si no se desea usar, se puede desactivar en el archivo de variables de
    entorno.
  * Según la naturaleza del proyecto final, es posible que sean necesarias otras
    herramientas adicionales.

## Instalación

* ### Proceso de instalación: [LANDO](https://lando.dev/)
  * Copiamos el contenido del proyecto en una carpeta de nuestra máquina[^1].
  * Establecemos los valores correctos en el archivo `.lando.yml` para la
    conexión con la base de datos y el nombre del proyecto.
  * Creamos el archivo `.env` a partir de `.env.example` y establecemos los
    valores a las variables.
  * Establecemos el nombre del proyecto en nuestro `composer.custom.json`.
  * Ejecutamos `lando start` para montar los contenedores del proyecto.

> [!CAUTION]
> Este proyecto incluye un script que se ejecuta como hook de Lando al
> ejecutar el comando `lando destroy`, se trata de un script propio del
> desarrollo de esta plantilla y quizás quieras eliminarlo para prevenir
> errores en tu proyecto (`./.lando/scripts/destroy_lando.sh`).

* ### Usuarios por defecto:

  Este script genera dos usuarios, el "administrador" y un usuario "gestor":

  |Role|Usuario|Contraseña|Correo electrónico|
  |---|---|---|---|
  |admin|admin|password|admin@example.com|
  |manager|manager|password|manager@example.com|

## Comandos personalizados para Drush

Este proyecto define dos comandos personalizados para ejecutarse con Drush.  
Se trata de una serie de comandos que facilitan la ejecución secuencial de otros
comandos aglutinando su ejecución en un sólo comando.

* ### custom:pre-commit

  El comando estandariza el procedimiento a seguir en Drupal tras ejecutar
  composer para actualizar módulos, unificando la ejecución de los siguientes
  comandos en uno solo:

  ```shell
  drush updatedb
  drush locale:check
  drush locale:update
  drush config:export
  drush cache:rebuild
  ```

* ### custom:deploy

  El comando estandariza el funcionamiento de los despliegues de Drupal,
  unificando la ejecución de los siguientes comandos en uno solo:

  ```shell
  drush updatedb
  drush config:import
  drush cache:rebuild
  drush deploy:hook
  drush locale:check
  drush locale:update
  drush config:import
  drush cache:rebuild
  ```

## Scripts

Este proyecto incluye una serie de scripts y su respectivo comando específico
para su uso con [Lando](https://lando.dev/).


## Otros scripts

* ### ./scripts/shell/share.sh
  > Script para generar un túnel y poder compartir nuestro proyecto local
  > fuera de nuestra red.

  Este script hace uso de [ngrok](https://ngrok.com/) por lo que será necesario
  crearse una cuenta y configurar el API Key en nuestro entorno local.
  Al ejecutarse se genera una url que podemos utilizar desde una máquina
  externa para conectarnos a nuestro sistema.

  > El script usa Lando para obtener la url pero no se puede ejecutar dentro
  > de Lando, por lo que no está disponible ningún atajo al comando.


[^1]: De forma opcional podemos usar el script [iniciar-proyecto](https://github.com/oscarnovasf/iniciar-proyecto) para descargar e iniciar un proyecto nuevo.

---

[version]: v1.0.0
[version-badge]: https://img.shields.io/badge/Versión-1.0.0-blue.svg

[license]: LICENSE.md
[license-badge]: https://img.shields.io/badge/Licencia-GPLv3+-green.svg "Leer la licencia"

[conduct]: CODE_OF_CONDUCT.md
[conduct-badge]: https://img.shields.io/badge/C%C3%B3digo%20de%20Conducta-2.0-4baaaa.svg "Código de conducta"

[changelog]: CHANGELOG.md "Histórico de cambios"