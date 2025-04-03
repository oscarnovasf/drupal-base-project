# custom:deploy

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

## Funciones de actualización de autoría

A continuación se muestran los 2 tipos de funciones de actualización ejecutadas por este comando, en orden.
Elija la más adecuada a sus necesidades.

| Function                                                                                                                  | Drupal API  | Purpose                          |
|---------------------------------------------------------------------------------------------------------------------------|-------------|----------------------------------|
| [HOOK_update_n()](https://api.drupal.org/api/drupal/core!lib!Drupal!Core!Extension!module.api.php/function/hook_update_N) | Not allowed | Low level changes.               |
| [HOOK_deploy_NAME()](https://github.com/drush-ops/drush/tree/HEAD/drush.api.php)                                          | Allowed     | Runs *after* config is imported. |

## Configuración

Si necesita personalizar este comando, debe utilizar la configuración de Drush para
los subcomandos listados arriba (e.j. updatedb, config:export, etc.).
