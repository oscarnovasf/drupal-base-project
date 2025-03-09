<?php

// phpcs:ignoreFile

/**
 * @file
 * Local development override configuration feature.
 */

$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/development.services.yml';

$settings['cache']['bins']['render']              = 'cache.backend.null';
$settings['cache']['bins']['dynamic_page_cache']  = 'cache.backend.null';
$settings['cache']['bins']['page']                = 'cache.backend.null';

$settings['extension_discovery_scan_tests'] = TRUE;
$settings['rebuild_access'] = TRUE;
$settings['skip_permissions_hardening'] = TRUE;
$settings['update_free_access'] = TRUE;

$config['system.logging']['error_level'] = 'verbose';

$config['system.performance']['css']['preprocess'] = FALSE;
$config['system.performance']['js']['preprocess']  = FALSE;

if (class_exists('Kint')) {
  // Change the maximum depth to prevent out-of-memory errors.
  \Kint::$depth_limit= 4;
}
