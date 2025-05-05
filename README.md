Drupal: Base Project
===

Plantilla para [Composer](https://getcomposer.org/) de instalación de Drupal.

[![version][version-badge]][changelog] [![Licencia][license-badge]][license] [![Código de conducta][conduct-badge]][conduct]
[![wakatime](https://wakatime.com/badge/user/236d57da-61e8-46f2-980b-7af630b18f42/project/f988ef5a-1e85-4d32-9121-75c552c747ec.svg)](https://wakatime.com/badge/user/236d57da-61e8-46f2-980b-7af630b18f42/project/f988ef5a-1e85-4d32-9121-75c552c747ec)

[![Donate][donate-badge]][donate-url] <img src="https://img.shields.io/liberapay/patrons/ONovasDev.svg?logo=liberapay">

# Tabla de Contenidos
1. [Requerimientos](#requerimientos)
2. [Recomendaciones](#recomendaciones)
3. [Instalación](#instalación)
4. [Comandos personalizados para Drush](#comandos-personalizados-para-drush)
5. [Scripts](#scripts)
6. [Otros scripts](#otros-scripts)
7. [FAQs](#faqs)

## Requerimientos

- ### Herramientas para desarrollo en máquina Local.
  - El proyecto está pensado para usar [Lando](https://lando.dev/) como entorno
    de desarrollo local.
  - Si se quiere poder enviar una url de nuestro proyecto en local con [Lando](https://lando.dev/),
    es necesario instalar y configurar [NGROK](https://ngrok.com/).

- ### Herramientas para servidores (dev, stg o pro)
  - Es necesario tener instalada la herramienta [JQ](https://stedolan.github.io/jq/)
    para la línea de comandos.
  - Es necesario tener instalada la herramienta [PV](http://www.ivarch.com/programs/pv.shtml)
    para la línea de comandos.

- ### Otros Requerimientos
  - El proyecto está pensado para hacer uso de *Redis* / *KeyDB*, por lo que
    será necesario tener acceso a una de estas herramientas.
    Si no se desea usar, se puede desactivar en el archivo de variables de
    entorno.
  - Según la naturaleza del proyecto final, es posible que sean necesarias otras
    herramientas adicionales.

## Recomendaciones
- Se recomienda usar [git flow](https://danielkummer.github.io/git-flow-cheatsheet/)

## Instalación

- ### Proceso de instalación: [LANDO](https://lando.dev/)
  - Copiamos el contenido del proyecto en una carpeta de nuestra máquina[^1].
  - Establecemos los valores correctos en el archivo `.lando.yml` para la
    conexión con la base de datos y el nombre del proyecto.
  - Creamos el archivo `.env` a partir de `.env.example` y establecemos los
    valores a las variables.
  - Establecemos el nombre del proyecto en nuestro `composer.custom.json`.
  - Ejecutamos `lando start` para montar los contenedores del proyecto.

> [!CAUTION]
> Este proyecto incluye un script que se ejecuta como hook de Lando al
> ejecutar el comando `lando destroy`, se trata de un script propio del
> desarrollo de esta plantilla y quizás quieras eliminarlo para prevenir
> errores en tu proyecto (`./.lando/scripts/destroy_lando.sh`).

- ### Usuarios por defecto:

  Este script genera dos usuarios, el "administrador" y un usuario "gestor":

  |Role|Usuario|Contraseña|Correo electrónico|
  |---|---|---|---|
  |admin|admin|password|admin@example.com|
  |manager|manager|password|manager@example.com|

## Comandos personalizados para Drush

Este proyecto define dos comandos personalizados para ejecutarse con Drush.
Se trata de una serie de comandos que facilitan la ejecución secuencial de otros
comandos aglutinando su ejecución en un sólo comando.

- ### custom:pre-commit

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

- ### custom:deploy

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

- ### ./scripts/shell/db.sh (`lando db`)
  Script para importar/exportar el contenido de la base de datos.
  Admite cualquiera de estos parámetros (sólo uno y obligatorio):

  |Parámetro|Descripción|
  |---|---|
  |**im**|Realiza la importación de la base de datos.|
  |**ex**|Realiza la exportación de la base de datos.|

- ### ./scripts/shell/dev.sh (`lando dev`)
  Script para cambiar el entorno del proyecto y aplicar las configuraciones
  apropiadas a cada entorno.
  Admite cualquiera de estos parámetros (sólo uno y obligatorio):

  |Parámetro|Descripción|
  |---|---|
  |**loc**|Cambia al entorno local importando su configuración específica.|
  |**dev**|Cambia al entorno de desarrollo importando su configuración específica.|
  |**stg**|Cambia al entorno de staging importando su configuración específica.|
  |**pro**|Cambia al entorno de producción importando su configuración específica.|

- ### ./scripts/shell/initialize.sh (`lando initialize`)
  Se encarga de reiniciar el proyecto eliminando todos los archivos y
  directorios que no están incluidos en el repositorio.

  |Parámetro|Descripción|
  |---|---|
  |**-y \| --yes**|Realiza la limpieza, si no se especifica sólo muestra los archivos que podrán ser eliminados.|
  |**-h \| --help**|Muestra la ayuda.|

- ### ./scripts/shell/trans.sh (`lando trans`)
  Script para importar/exportar las traducciones (excepto el inglés).
  Admite cualquiera de estos parámetros (sólo uno y obligatorio):

  |Parámetro|Descripción|
  |---|---|
  |**im**|Realiza la importación de las traducciones.|
  |**ex**|Realiza la exportación de las traducciones.|


## Otros scripts

- ### ./scripts/shell/share.sh
  Script para generar un túnel y poder compartir nuestro proyecto local
  fuera de nuestra red.

  Este script hace uso de [ngrok](https://ngrok.com/) por lo que será necesario
  crearse una cuenta y configurar el API Key en nuestro entorno local.
  Al ejecutarse se genera una url que podemos utilizar desde una máquina
  externa para conectarnos a nuestro sistema.

  Uno de los usos básicos de este script es para poder gestionar localmente los
  callbacks de algunas funcionalidades con proveedores externos (ej. banca).

> [!NOTE]
> El script usa Lando para obtener la url pero no se puede ejecutar dentro
> de Lando, por lo que no está disponible ningún atajo al comando y debe
> ejecutarse con la ruta completa.

## FAQs

* ### ¿Cómo especificar una versión concreta de PHP?

  En este proyecto se usa la versión de PHP 8.3 como mínimo
  (ver [System Requirements](https://www.drupal.org/docs/getting-started/system-requirements/overview)),
  pero es posible que al usar `composer update` se actualicen algunos paquetes
  con un requerimiento superior.

  Para evitar esto puedes indicar en la sección `config` del `composer.json` la
  versión que quieres usar:

  ```json
  "config": {
      "platform": {
          "php": "8.3.0"
      }
  },
  ```

* ### ¿Cómo proteger archivos para no ser sobrescritos?

  En algún proyecto nos puede interesar no sobrescribir archivos como el
  *.htaccess* o el *robots.txt*. Para eso bastará con añadir lo siguiente al
  archivo `composer.json`:

  ```json
  "file-mapping": {
      ...
      "[web-root]/robots.txt": false,
      "[web-root]/.htaccess": false,
      "[web-root]/.ht.router.php": false
  },
  ```

* ### ¿Cómo aplicar un parche al proyecto?

  La gestión de parches para el sistema está alojada en la carpeta:
  `./config/patches/` en el archivo *composer.patches.json*.

  Se recomienda que, siempre que sea posible, se descarguen los parches que
  serán aplicados dentro de su propia carpeta.

  Por ejemplo, para un parche del core de drupal se generará la siguiente
  estructura:

  ```yml
  - config
    - patches
      - core
        - archivo.patch
  ```


[^1]: De forma opcional podemos usar el script [iniciar-proyecto](https://github.com/oscarnovasf/iniciar-proyecto) para descargar e iniciar un proyecto nuevo.

---

[version]: v1.0.0
[version-badge]: https://img.shields.io/badge/Versión-1.0.0-blue.svg

[license]: LICENSE.md
[license-badge]: https://img.shields.io/badge/Licencia-GPLv3+-green.svg "Leer la licencia"

[conduct]: CODE_OF_CONDUCT.md
[conduct-badge]: https://img.shields.io/badge/C%C3%B3digo%20de%20Conducta-2.0-4baaaa.svg "Código de conducta"

[changelog]: CHANGELOG.md "Histórico de cambios"

[donate-badge]: https://img.shields.io/badge/Donaci%C3%B3n-PayPal-red.svg
[donate-url]: https://paypal.me/oscarnovasf "Haz una donación"
