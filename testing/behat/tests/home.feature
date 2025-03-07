Feature: Homepage

  Funcionalidades de la página de inicio

  @asc
  Scenario: Ver la página de inicio
    Given I am not logged in
      And I go to the homepage

     Then the response status code should be 200
      And I should see "Descubre el seguro médico que mejor se adapta a ti"
