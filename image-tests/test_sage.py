#!/usr/bin/env python3
import nbformat
import os
from nbclient import NotebookClient
from pathlib import Path


def run_notebook(notebook, kernel_name="python3"):
    notebook_path = os.path.join("image-tests", "notebooks", notebook)

    try:
        nb = nbformat.read(notebook_path, as_version=4)
    except FileNotFoundError:
        return False

    client = NotebookClient(
        nb,
        timeout=600,
        kernel_name=kernel_name,
        resources={"metadata": {"path": str(Path(notebook_path).parent)}},
    )

    try:
        client.execute()
    except Exception:
        return False

    return True


def test_sage_examples_notebook_execution():
    assert run_notebook("sage-notebook-test.ipynb", kernel_name="sagemath")
