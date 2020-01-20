# # import pytest
import re
import time
from selenium.webdriver.support.ui import Select
from selenium.webdriver.common.keys import Keys


def test_start_page(selenium, base_url):
    selenium.get(base_url + '/index.xql')
    assert 'MEGA' in selenium.title


def test_start_page_search(selenium, base_url):
    selenium.get(base_url + '/index.xql')
    selenium.find_element_by_id('searchstring').clear()
    selenium.find_element_by_id('searchstring').send_keys('Marx')
    selenium.find_element_by_css_selector('button.submit').click()
    assert 'Es wurden keine Dokumente gefunden.' not in selenium.page_source


def test_editorial_remarks(selenium, base_url):
    selenium.get(base_url + '/about/text.xql?id=aufbau_edition')
    h1 = selenium.find_element_by_css_selector('header h1')
    assert 'Editorische Hinweise' in h1.text


def test_letters(selenium, base_url):
    selenium.get(base_url + '/briefe/index.xql')
    h1 = selenium.find_element_by_css_selector('header h1')
    assert 'Briefwechsel insgesamt' in h1.text


def test_letters_index(selenium, base_url):
    selenium.get(base_url + '/briefe/index.xql')
    letter_list = selenium.find_elements_by_css_selector('table.letters tbody tr')
    assert len(letter_list) > 1


def test_excerpts(selenium, base_url):
    selenium.get(base_url + '/exzerpte/index.xql')
    h1 = selenium.find_element_by_css_selector('header h1')
    assert 'Exzerpte und Notizen' in h1.text


def test_registers(selenium, base_url):
    selenium.get(base_url + '/register/index.xql')
    h1 = selenium.find_element_by_css_selector('header h1')
    assert 'Register' in h1.text


def test_registers_complete(selenium, base_url):
    selenium.get(base_url + '/register/index.xql')

    def all_registers_exist():
        names_expr = r'Namen \((?!0)\d{2,}\)'
        names_match = re.search(names_expr, selenium.page_source)
        institutions_expr = r'Firmen \((?!0)\d{2,}\)'
        institutions_match = re.search(institutions_expr, selenium.page_source)
        places_expr = r'Orte \(im Aufbau\)'
        places_match = re.search(places_expr, selenium.page_source)
        subjects_expr = r'Themen'
        subjects_match = re.search(subjects_expr, selenium.page_source)
        return bool(names_match) and bool(institutions_match) and bool(places_match) and bool(subjects_match)
    assert all_registers_exist(), 'Not all registers seem to exist'


def test_search_page(selenium, base_url):
    selenium.get(base_url + '/suche/index.xql')
    h1 = selenium.find_element_by_css_selector('header h1')
    assert 'Suche in den Texten' in h1.text


def test_search_text(selenium, base_url):
    selenium.get(base_url + '/suche/index.xql')
    selenium.find_element_by_css_selector('div.grid_8 #search input[name=q_text]').clear()
    selenium.find_element_by_css_selector('div.grid_8 #search input[name=q_text]').send_keys('Polizei')
    selenium.find_element_by_css_selector('div.grid_8 #search input.submit[type=submit]').click()
    assert 'Es wurden keine Dokumente gefunden.' not in selenium.page_source


def test_search_title(selenium, base_url):
    selenium.get(base_url + '/suche/index.xql')
    selenium.find_element_by_css_selector('div.grid_8 #search input[name=q_title]').clear()
    selenium.find_element_by_css_selector('div.grid_8 #search input[name=q_title]').send_keys('Engels')
    selenium.find_element_by_css_selector('div.grid_8 #search input.submit[type=submit]').click()
    assert 'Es wurden keine Dokumente gefunden.' not in selenium.page_source


def test_search_note(selenium, base_url):
    selenium.get(base_url + '/suche/index.xql')
    selenium.find_element_by_css_selector('div.grid_8 #search input[name=q_note]').clear()
    selenium.find_element_by_css_selector('div.grid_8 #search input[name=q_note]').send_keys('Kongress')
    selenium.find_element_by_css_selector('div.grid_8 #search input.submit[type=submit]').click()
    assert 'Es wurden keine Dokumente gefunden.' not in selenium.page_source


def test_search_zeugenbeschreibung(selenium, base_url):
    selenium.get(base_url + '/suche/index.xql')
    selenium.find_element_by_css_selector('div.grid_8 #search input[name=q_zb]').clear()
    selenium.find_element_by_css_selector('div.grid_8 #search input[name=q_zb]').send_keys('Papier')
    selenium.find_element_by_css_selector('div.grid_8 #search input.submit[type=submit]').click()
    assert 'Es wurden keine Dokumente gefunden.' not in selenium.page_source


def test_search_correspondent(selenium, base_url):
    selenium.get(base_url + '/suche/index.xql')
    select = Select(selenium.find_element_by_css_selector('select[name=korrespondent]'))
    select.select_by_visible_text('Marx, Eleanor')
    selenium.find_element_by_css_selector('div.grid_8 #search input.submit[type=submit]').click()
    assert 'Es wurden keine Dokumente gefunden.' not in selenium.page_source


def test_search_by_date(selenium, base_url):
    selenium.get(base_url + '/suche/index.xql')
    selenium.find_element_by_css_selector('div.grid_8 #search input[name=q_text]').clear()
    selenium.find_element_by_css_selector('div.grid_8 #search input[name=q_text]').send_keys('Polizei')
    selenium.find_element_by_css_selector('div.grid_8 #search input[name=startDate]').clear()
    selenium.find_element_by_css_selector('div.grid_8 #search input[name=startDate]').send_keys('1866-01-10')
    selenium.find_element_by_css_selector('div.grid_8 #search input[name=endDate]').clear()
    selenium.find_element_by_css_selector('div.grid_8 #search input[name=endDate]').send_keys('1866-01-20')
    selenium.find_element_by_css_selector('div.grid_8 #search input.submit[type=submit]').click()
    assert 'Es wurden keine Dokumente gefunden.' not in selenium.page_source


def test_search_autosuggest(selenium, base_url):
    selenium.get(base_url + '/register/index.xql')
    selenium.find_element_by_id('personname').click()
    selenium.find_element_by_id('personname').send_keys('Humbo')
    time.sleep(3)  # Give autosuggest some time to come up
    selenium.find_element_by_id('personname').send_keys(Keys.ARROW_DOWN)
    selenium.find_element_by_id('personname').send_keys(Keys.ENTER)
    selenium.find_element_by_id('personname').send_keys(Keys.TAB)
    selenium.find_element_by_id('personname').send_keys(Keys.ENTER)
    time.sleep(2)  # Wait for new page to load
    h1 = selenium.find_element_by_css_selector('header h1')
    assert 'Humboldt, Alexander' in h1.text
