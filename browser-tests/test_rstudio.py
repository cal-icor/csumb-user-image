import re
import pytest
from playwright.sync_api import Page, expect

JUPYTER_URL = "http://localhost:8888"
RSTUDIO_URL = f"{JUPYTER_URL}/rstudio/"

# RStudio takes several seconds to start on first proxy hit.
RSTUDIO_LOAD_TIMEOUT = 60_000   # ms
CONSOLE_READY_TIMEOUT = 30_000  # ms
OUTPUT_TIMEOUT = 15_000         # ms


@pytest.fixture(scope="session")
def rstudio_page(browser):
    """
    Single browser session shared across all tests.
    Opens RStudio once and keeps it open so subsequent tests don't
    pay the rsession startup cost again.
    """
    page = browser.new_page()
    page.goto(RSTUDIO_URL, timeout=RSTUDIO_LOAD_TIMEOUT)
    page.wait_for_load_state("load", timeout=RSTUDIO_LOAD_TIMEOUT)
    # Wait for the console output pane to appear, confirming rsession has started.
    page.wait_for_selector("#rstudio_console_output", timeout=RSTUDIO_LOAD_TIMEOUT)
    yield page
    page.close()


def _type_in_console(page: Page, code: str):
    """Click the console ACE editor surface and type a command, then press Enter."""
    page.locator("#rstudio_console_input .ace_scroller").click()
    page.keyboard.type(code)
    page.keyboard.press("Enter")


def test_rstudio_page_loads(rstudio_page: Page):
    """RStudio proxy is reachable and the IDE frame loads."""
    expect(rstudio_page).to_have_title(
        re.compile(r"rstudio", re.IGNORECASE),
        timeout=RSTUDIO_LOAD_TIMEOUT,
    )


def test_rstudio_console_present(rstudio_page: Page):
    """The R console output pane is visible, confirming rsession started."""
    expect(rstudio_page.locator("#rstudio_console_output")).to_be_visible(
        timeout=CONSOLE_READY_TIMEOUT
    )


def test_rstudio_r_version(rstudio_page: Page):
    """R version shown in the console header matches the pinned version."""
    expect(rstudio_page.locator("#rstudio_console_interpreter_version")).to_have_text(
        re.compile(r"R 4\.5\.1"),
        timeout=CONSOLE_READY_TIMEOUT,
    )


def test_rstudio_library_load(rstudio_page: Page):
    """tidyverse loads without error in the RStudio console."""
    _type_in_console(rstudio_page, "library(tidyverse)")
    rstudio_page.wait_for_timeout(8_000)
    expect(rstudio_page.locator("#rstudio_console_output")).not_to_contain_text(
        "Error in library", timeout=OUTPUT_TIMEOUT
    )


def test_rstudio_basic_computation(rstudio_page: Page):
    """A simple computation runs and returns the expected value."""
    _type_in_console(rstudio_page, "cat(1 + 1, '\\n')")
    expect(rstudio_page.locator("#rstudio_console_output")).to_contain_text(
        "2", timeout=OUTPUT_TIMEOUT
    )
