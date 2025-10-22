FROM rocker/rstudio:4.5.1

ENV NB_USER=rstudio
ENV NB_UID=1000
ENV CONDA_DIR=/srv/conda
ENV NB_PYTHON_PREFIX=${CONDA_DIR}/envs/notebook

# Set ENV for all programs...
ENV PATH=${CONDA_DIR}/bin:$PATH

# And set ENV for R! It doesn't read from the environment...
RUN echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron.site

# Add PATH to /etc/profile so it gets picked up by the terminal
RUN echo "PATH=${PATH}" >> /etc/profile
RUN echo "export PATH" >> /etc/profile

ENV HOME=/home/${NB_USER}

WORKDIR ${HOME}

# Install packages needed by notebook-as-pdf
# nodejs for installing notebook / jupyterhub from source
# libarchive-dev for https://github.com/berkeley-dsep-infra/datahub/issues/1997
# texlive-xetex pulls in texlive-latex-extra > texlive-latex-recommended
# We use Ubuntu's TeX because rocker's doesn't have most packages by default,
# and we don't want them to be downloaded on demand by students.
# tini is necessary because it is our ENTRYPOINT below.
RUN apt-get update > /dev/null && \
    apt-get install --yes \
            less \
            libx11-xcb1 \
            libxtst6 \
            libxrandr2 \
            # libasound2 \
            liboss4-salsa-asound2 \
            libpangocairo-1.0-0 \
            libatk1.0-0 \
            libatk-bridge2.0-0 \
            libgtk-3-0 \
            libnss3 \
            libnspr4 \
            libxss1 \
            libz-dev \
            fonts-symbola \
            gdebi-core \
            tini \
	        pandoc \
            texlive-xetex \
            texlive-fonts-recommended \
            texlive-fonts-extra \
            texlive-plain-generic \
            nodejs npm > /dev/null && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY install-miniforge.bash /tmp/install-miniforge.bash
RUN /tmp/install-miniforge.bash

# needed for building on mac see DH-394
RUN chown -Rh ${NB_USER}:${NB_USER} ${HOME}

USER ${NB_USER}

COPY environment.yml /tmp/environment.yml
RUN mamba env update -q -p ${CONDA_DIR} -f /tmp/environment.yml && \
    mamba clean -afy

# DH-331, very similar to what was done for datahub in DH-164
ENV PLAYWRIGHT_BROWSERS_PATH=${CONDA_DIR}
RUN playwright install chromium

# Install IRKernel
# RUN R --quiet -e "install.packages('IRkernel', quiet = TRUE)" && \
#     R --quiet -e "IRkernel::installspec(prefix='${CONDA_DIR}')"

COPY install.R /tmp/install.R
RUN Rscript /tmp/install.R

# Use simpler locking strategy
COPY file-locks /etc/rstudio/file-locks

# installing chromium browser to enable webpdf conversion using nbconvert
ENV PLAYWRIGHT_BROWSERS_PATH=${CONDA_DIR}
RUN playwright install chromium

# https://github.com/berkeley-dsep-infra/datahub/issues/5827
RUN git config --system pull.rebase false

# overrides.json is a file that jupyterlab reads to determine some settings
# 1) remove the 'create shareable link' option from the filebrowser context menu
RUN mkdir -p ${NB_PYTHON_PREFIX}/share/jupyter/lab/settings
COPY overrides.json ${NB_PYTHON_PREFIX}/share/jupyter/lab/settings

# code-server's conda package assets are installed in share/code-server.
ENV VSCODE_EXTENSIONS=${CONDA_DIR}/envs/notebook/share/code-server/extensions
RUN mkdir -p ${VSCODE_EXTENSIONS}

# This is not reproducible, and it can be difficult to version these.
RUN for x in \
  ms-toolsai.jupyter \
  ms-python.python \
  quarto.quarto \
  ms-vscode.live-server \
  posit.shiny \
  reditorsupport.r \
  ; do code-server --extensions-dir ${VSCODE_EXTENSIONS} --install-extension $x; done

# Doing a little cleanup
RUN rm -rf /tmp/downloaded_packages
RUN rm -rf ${HOME}/.cache

USER root
ENV REPO_DIR=/srv/repo
# COPY --chown=${NB_USER}:${NB_USER} image-tests ${REPO_DIR}/image-tests
USER ${NB_USER}

ENTRYPOINT ["tini", "--"]
