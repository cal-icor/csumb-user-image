# <HUBNAME>-user-image

See this repository's [CONTRIBUTING.md](https://github.com/cal-icor/<HUBNAME>-user-image/blob/main/CONTRIBUTING.md) for instructions. That information will eventually be migrated to docs.datahub.berkeley.edu.

# building the image locally

You should use [repo2-docker](https://repo2docker.readthedocs.io/en/latest/) to build and use/test the image on your own device before you push and create a PR.  It's better (and typically faster) to do this first before using CI/CD.  There's no need to waste Github Action minutes to test build images when you can do this on your own device!

Run `repo2docker` from inside the cloned image repo.  To run on a linux/WSL2 linux shell:
```
repo2docker . # <--- the path to the repo
```

If you are using an ARM CPU (Apple M* silicon), you will need to run `jupyter-repo2docker` with the following arguments:

```
jupyter-repo2docker --user-id=1000 --user-name=jovyan \
  --Repo2Docker.platform=linux/amd64 \
  --target-repo-dir=/home/jovyan/.cache \
  -e PLAYWRIGHT_BROWSERS_PATH=/srv/conda \
  . # <--- the path to the repo
```

If you just want to see if the image builds, but not automatically launch the server, add `--no-run` to the arguments (before the final `.`).
