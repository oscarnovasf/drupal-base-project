# custom:pre-commit

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

## Configuración

Si necesita personalizar este comando, debe utilizar la configuración de Drush para
los subcomandos listados arriba (e.j. updatedb, config:export, etc.).
