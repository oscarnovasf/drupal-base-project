<?php

namespace Drush\Commands\custom;

use Consolidation\SiteAlias\SiteAlias;
use Consolidation\SiteAlias\SiteAliasManagerAwareTrait;
use Consolidation\SiteProcess\ProcessManager;
use Drush\Attributes as CLI;
use Drush\Boot\DrupalBootLevels;
use Drush\Drush;
use Drush\SiteAlias\SiteAliasManagerAwareInterface;

/**
 * Custom deploy drush commands.
 */
final class CustomDeployCommands extends DrushCommands implements SiteAliasManagerAwareInterface {

  use SiteAliasManagerAwareTrait;

  private const DEPLOY = 'custom:deploy';

  private const PRE_COMMIT = 'custom:pre-commit';

  /**
   * Run updates, config import, deploy hooks and locale updates.
   */
  #[CLI\Command(name: self::DEPLOY)]
  #[CLI\Usage(name: 'drush ' . self::DEPLOY, description: 'Run updates, config import, deploy hooks and locale updates.')]
  #[CLI\Topics(topics: [CustomDocsCommands::DEPLOY])]
  #[CLI\Bootstrap(level: DrupalBootLevels::FULL)]
  public function deploy(): void {
    $self = $this->siteAliasManager()->getSelf();
    $redispatchOptions = Drush::redispatchOptions();
    $manager = $this->processManager();

    $this->runCommand($manager, $self, $redispatchOptions, 'updatedb', 'Database updates start');
    $this->runCommand($manager, $self, $redispatchOptions, 'config:import', 'Config import start');
    $this->runCommand($manager, $self, $redispatchOptions, 'cache:rebuild', 'Cache rebuild start');
    $this->runCommand($manager, $self, $redispatchOptions, 'deploy:hook', 'Deploy hook start');
    $this->runCommand($manager, $self, $redispatchOptions, 'locale:check', 'Locale check start');
    $this->runCommand($manager, $self, $redispatchOptions, 'locale:update', 'Locale update start');
    $this->runCommand($manager, $self, $redispatchOptions, 'config:import', 'Config import start');
    $this->runCommand($manager, $self, $redispatchOptions, 'cache:rebuild', 'Cache rebuild start');
  }

  /**
   * Run updates, locale updates and config export.
   */
  #[CLI\Command(name: self::PRE_COMMIT)]
  #[CLI\Usage(name: 'drush ' . self::PRE_COMMIT, description: 'Run updates, locale updates and config export.')]
  #[CLI\Topics(topics: [CustomDocsCommands::PRE_COMMIT])]
  #[CLI\Bootstrap(level: DrupalBootLevels::FULL)]
  public function preCommit(): void {
    $self = $this->siteAliasManager()->getSelf();
    $redispatchOptions = Drush::redispatchOptions();
    $manager = $this->processManager();

    $this->runCommand($manager, $self, $redispatchOptions, 'updatedb', 'Database updates start');
    $this->runCommand($manager, $self, $redispatchOptions, 'locale:check', 'Locale check start');
    $this->runCommand($manager, $self, $redispatchOptions, 'locale:update', 'Locale update start');
    $this->runCommand($manager, $self, $redispatchOptions, 'config:export', 'Config export start');
    $this->runCommand($manager, $self, $redispatchOptions, 'cache:rebuild', 'Cache rebuild start');
  }

  /**
   * Run command.
   *
   * @param \Consolidation\SiteProcess\ProcessManager $manager
   *   Process manager.
   * @param \Consolidation\SiteAlias\SiteAlias $self
   *   Site alias.
   * @param array $redispatchOptions
   *   Redispatch options.
   * @param string $command
   *   Drush command.
   * @param string $message
   *   Success message.
   */
  private function runCommand(
    ProcessManager $manager,
    SiteAlias $self,
    array $redispatchOptions,
    string $command,
    string $message,
  ): void {
    $this->printSuccessMessage($message);
    // @phpstan-ignore-next-line
    $process = $manager->drush($self, $command, [], $redispatchOptions);
    $process->mustRun($process->showRealtime());
  }

  /**
   * Print success message.
   *
   * @param string $message
   *   Message.
   */
  private function printSuccessMessage(string $message): void {
    $message = sprintf('[%s] %s', date('Y-m-d H:i:s'), $message);
    $this->logger()?->success($message);
  }

}
