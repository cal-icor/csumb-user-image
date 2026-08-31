#!/usr/bin/env python3
import subprocess
import sys
from pathlib import Path

import pytest

_QUARTO_DOC = Path("image-tests/quarto/smoke-test.qmd")


def _render(fmt, output_dir):
    result = subprocess.run(
        ["quarto", "render", str(_QUARTO_DOC), "--to", fmt, "--output-dir", str(output_dir)],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print(result.stdout)
        print(result.stderr, file=sys.stderr)
    return result


@pytest.mark.parametrize(
    "fmt,output_ext",
    [
        ("pdf", "pdf"),
        ("typst", "pdf"),
        ("html", "html"),
    ],
)
def test_quarto_render(fmt, output_ext, tmp_path):
    result = _render(fmt, tmp_path)
    assert result.returncode == 0, f"quarto render --to {fmt} failed:\n{result.stderr}"
    output_file = tmp_path / f"smoke-test.{output_ext}"
    assert output_file.exists(), f"quarto render --to {fmt} did not produce {output_file}"
    assert output_file.stat().st_size > 0
