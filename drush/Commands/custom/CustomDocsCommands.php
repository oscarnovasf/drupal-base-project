<?php

namespace Drush\Commands\custom;

use Drush\Attributes as CLI;

/**
 * Topic commands.
 *
 * Any command file may add topics.
 * Use the Topic attribute to indicate the command is a topic.
 */
final class CustomDocsCommands extends DrushCommands {

  public const DEPLOY = 'docs:custom:deploy';

  public const PRE_COMMIT = 'docs:custom:pre-commit';

  /**
   * Custom deploy command for Drupal.
   */
  #[CLI\Command(name: self::DEPLOY)]
  #[CLI\Help(hidden: TRUE)]
  #[CLI\Topics(path: './docs/custom_deploy_command.md')]
  public function deploy(): void {
    if ($this->commandData) {
      $this->printFileTopic($this->commandData);
    }
  }

  /**
   * Custom sync update command for Drupal.
   */
  #[CLI\Command(name: self::PRE_COMMIT)]
  #[CLI\Help(hidden: TRUE)]
  #[CLI\Topics(path: './docs/custom_pre_commit_command.md')]
  public function preCommit(): void {
    if ($this->commandData) {
      $this->printFileTopic($this->commandData);
    }
  }

}
