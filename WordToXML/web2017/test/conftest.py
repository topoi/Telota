# conftest.py

import pytest

# Define a fixture to make selenium instance available for  tests

@pytest.fixture
def selenium(request):
    from selenium import webdriver
    selenium = webdriver. Firefox()
    request.addfinalizer(selenium.close)
    return selenium
