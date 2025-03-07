<?php

/**
 * @file
 * Behat Feature Context file.
 */

use Behat\Behat\Hook\Scope\AfterStepScope;
use Behat\Mink\Exception\DriverException;
use Behat\Mink\Exception\ElementNotFoundException;

use Drupal\DrupalExtension\Context\DrupalContext;

/**
 * Main project custom context.
 */
class FeatureContext extends DrupalContext {

  /**
   * @AfterStep
   */
  public function takeScreenshotAfterFailedStep(AfterStepScope $scope) {
    if (!$scope->getTestResult()->isPassed()) {
      $this->takeScreenshot('error');
    }
  }

  /**
   * @Given I am logged in as insured :name
   */
  public function iAmLoggedInAsInsured($name) {
    $domain = $this->getMinkParameter('base_url');

    /** @var \Namespace\To\DrushDriver $driver */
    $driver = $this->getDriver('drush');
    $uli = $driver->drush('uli', [
      "--name '" . $name . "'",
      "--browser=0",
      "--uri=$domain",
    ]);

    // Trim EOL characters.
    $uli = trim($uli);

    // Log in.
    $this->getSession()->visit($uli);
  }

  /**
   * @Then I should see a select with the name :selectName
   */
  public function iShouldSeeSelectWithName($selectName) {
    $select = $this->getSession()->getPage()->find('css', sprintf('select[name="%s"]', $selectName));
    if (NULL === $select) {
      throw new Exception(sprintf('The select with name "%s" was not found on the page.', $selectName));
    }
  }

  /**
   * @Given I select the first option from the :selectName select
   */
  public function iSelectTheFirstOptionFromTheSelect($selectName) {
    $select = $this->getSession()->getPage()->find('css', sprintf('select[name="%s"]', $selectName));
    if (NULL === $select) {
      throw new Exception(sprintf('The select with name "%s" was not found on the page.', $selectName));
    }
    // Seleccionar la primera opción que no sea vacía.
    $options = $select->findAll('css', 'option');
    if (!empty($options)) {
      foreach ($options as $option) {
        if ($option->getAttribute('value') != '') {
          $option->click();
          return;
        }
      }
    }
    throw new Exception('No options were found in the select.');
  }

  /**
   * @When I press the search submit button :id
   */
  public function iPressTheSearchSubmitButton($id) {
    $button = $this->getSession()->getPage()->find('css', '#' . $id);
    if (NULL === $button) {
      throw new Exception('The button could not be found');
    }
    $button->click();
  }

  /**
   * @Then /^the URL should change to "([^"]*)"$/
   */
  public function theUrlShouldChangeTo($expectedUrl) {
    $this->spin(function ($context) use ($expectedUrl) {
      $currentUrl = $context->getSession()->getCurrentUrl();
      $expected = $context->locatePath($expectedUrl);
      return strpos($currentUrl, $expected) !== FALSE;
    });
  }

  /**
   * @When /^I click on the link with attr-id "([^"]*)" and id "([^"]*)"$/
   */
  public function iClickOnTheLinkWithAttrIdAndId($attrId, $id) {
    // Buscar el elemento por CSS selector usando los atributos proporcionados.
    $selector = "a[attr-id='$attrId'][id='$id']";
    $session = $this->getSession();
    $element = $session->getPage()->find('css', $selector);

    // Si el elemento no se encuentra, lanzar una excepción.
    if (NULL === $element) {
      throw new ElementNotFoundException(
        $session, 'link', 'css', $selector
      );
    }

    // Hacer clic en el elemento.
    $element->click();

    // Esperar a que la petición AJAX se complete.
    $this->waitForAjax();
  }

  /**
   * @Then /^I take a screenshot$/
   */
  public function iTakeScreenshot() {
    $this->takeScreenshot('info');
  }

  /**
   * Espera a que la petición AJAX se complete o se agote el tiempo de espera.
   */
  private function waitForAjax() {
    $this->getSession()->wait(5000, '(typeof jQuery !== "undefined" && jQuery.active === 0)');
  }

  /**
   * Captura de pantalla a un archivo.
   */
  private function takeScreenshot($type) {
    $driver = $this->getSession()->getDriver();
    $date = date('Y-m-d_H-i-s');

    switch ($type) {

      case 'error':
        $fileName = sprintf('error-%s.png', $date);
        $filePath = DRUPAL_ROOT . '/../testing/behat/screen_shots/errors/';

        $file = $filePath . $fileName;
        break;

      default:
        $fileName = sprintf('info-%s.png', $date);
        $filePath = DRUPAL_ROOT . '/../testing/behat/screen_shots/info/';

        $file = $filePath . $fileName;
        break;

    }

    try {
      // Verifica si la ruta ya existe.
      if (!file_exists($filePath)) {
        if (!mkdir($filePath, 0775, TRUE)) {
          // Si la creación del directorio falla, lanza una excepción.
          throw new Exception("Error al crear el directorio: " . $filePath);
        }
      }

      file_put_contents($file, $driver->getScreenshot());
    }
    catch (DriverException $e) {
      echo "Error al tomar la captura de pantalla: " . $e->getMessage();
    }
  }

  /**
   * Temporizador.
   */
  private function spin($lambda, $wait = 60) {
    for ($i = 0; $i < $wait; $i++) {
      try {
        if ($lambda($this)) {
          return TRUE;
        }
      }
      catch (Exception $e) {
        // No hacer nada.
      }

      sleep(1);
    }

    $backtrace = debug_backtrace();

    throw new Exception(
      "El tiempo de espera para la operación ha expirado en " . $backtrace[1]['function']
    );
  }

}
