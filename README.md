# Drupal: Base Project
---

[![version][version-badge]][changelog] [![Licencia][license-badge]][license] [![Código de conducta][conduct-badge]][conduct]

> [!IMPORTANT]
> Plantilla para [Composer](https://getcomposer.org/) de instalación de Drupal.

## Requerimientos

* ### Herramientas para desarrollo en máquina Local.
  * El proyecto está pensado para usar [Lando](https://lando.dev/) como entorno
    de desarrollo local.
  * Si se quiere poder enviar una url de nuestro proyecto en local con [Lando](https://lando.dev/),
    es necesario instalar y configurar [NGROK](https://ngrok.com/).

* ### Herramientas para servidores (pre, stg o pro)
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


---

[version]: v1.0.0
[version-badge]: https://img.shields.io/badge/Versión-1.0.0-blue.svg

[license]: LICENSE.md
[license-badge]: https://img.shields.io/badge/Licencia-GPLv3+-green.svg "Leer la licencia"

[conduct]: CODE_OF_CONDUCT.md
[conduct-badge]: https://img.shields.io/badge/C%C3%B3digo%20de%20Conducta-2.0-4baaaa.svg "Código de conducta"

[changelog]: CHANGELOG.md "Histórico de cambios"