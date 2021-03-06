Feature: Anchor link

  As a citizen I need to be able to scroll to a section in the page content when clicking an anchor link

  Scenario: Visit a url with anchor link via link
    Given the "/anchorlink-test" page exists with fixture "page/anchorlinktest" data
    When I visit the page "/anchorlink-test"
    And I click the link "/demo-landing-page#accordion-header-basic"
    And I wait for 10 seconds
    Then the page should scroll to "#accordion-header-basic"

  Scenario: Visit a url with anchor link
    Given I visit the page "/demo-landing-page#accordion-header-basic"
    And the page should scroll to "#accordion-header-basic"
  
