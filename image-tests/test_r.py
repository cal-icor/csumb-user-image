#!/usr/bin/env python3
import subprocess
import sys
from pathlib import Path

_R_DIR = Path("image-tests/r")


def _run_rscript(script_path):
    result = subprocess.run(
        ["Rscript", str(script_path)],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print(result.stdout)
        print(result.stderr, file=sys.stderr)
    return result


def test_r_core():
    result = _run_rscript(_R_DIR / "test_r_core.R")
    assert result.returncode == 0, f"R core tests failed:\n{result.stderr}"
    assert "R core tests passed" in result.stdout


def test_r_csumb():
    result = _run_rscript(_R_DIR / "test_r_csumb.R")
    assert result.returncode == 0, f"R CSUMB-specific tests failed:\n{result.stderr}"
    assert "R CSUMB-specific tests passed" in result.stdout
