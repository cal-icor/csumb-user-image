FROM us-central1-docker.pkg.dev/cal-icor-hubs/user-images/base-user-image:HASH AS base

USER root

# Do not exclude manpages from being installed.
RUN sed -i '/usr.share.man/s/^/#/' /etc/dpkg/dpkg.cfg.d/excludes

# Reinstall coreutils so that basic man pages are installed. Due to dpkg's
# exclusion, they were not originally installed.
RUN apt --reinstall install coreutils

# Install all apt packages
COPY apt.txt /tmp/apt.txt
RUN apt-get -qq update --yes && \
    apt-get -qq install --yes --no-install-recommends \
        $(grep -v ^# /tmp/apt.txt) && \
    apt-get -qq purge && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/*

# From docker-ce-packaging
# Remove diverted man binary to prevent man-pages being replaced with "minimized" message. See docker/for-linux#639
RUN if  [ "$(dpkg-divert --truename /usr/bin/man)" = "/usr/bin/man.REAL" ]; then \
        rm -f /usr/bin/man; \
        dpkg-divert --quiet --remove --rename /usr/bin/man; \
    fi

RUN mandb -c

# =============================================================================
# This stage exists to build /srv/r.
FROM base AS srv-r

USER root
# Create user owned R libs dir
# This lets users temporarily install packages
RUN install -d -o ${NB_USER} -g ${NB_USER} ${R_LIBS_USER}

# Install R libraries as our user
USER ${NB_USER}

# Install R packages
COPY install.R /tmp/
RUN /tmp/install.R

# =============================================================================
# This stage exists to build /srv/conda.
FROM base AS srv-conda

# USER root
# Create user owned obitools dir
# This lets users temporarily install packages
RUN install -d -o ${NB_USER} -g ${NB_USER} ${OBITOOLS_DIR}

# Install conda environment as our user
USER ${NB_USER}

# Install Conda packages
ENV PATH=${CONDA_DIR}/bin:$PATH
COPY environment.yml /tmp/environment.yml
RUN mamba env update -q -y -n notebook -f /tmp/environment.yml
RUN mamba clean -afy

# Register the SageMath Jupyter kernel so it appears in the launcher.
# The conda-forge sagelib `sage` wrapper does not accept `-python`; invoke the
# env python directly to install the kernelspec.
RUN python -m sage.repl.ipython_kernel.install --sys-prefix

# install bioconda packages
COPY bioinformatics.yaml /tmp/bioinformatics.yaml
COPY bioinformatics-install.sh /tmp/bioinformatics-install.sh
RUN /tmp/bioinformatics-install.sh

# install molecularecology packages
COPY molecularecology.yaml /tmp/molecularecology.yaml
COPY molecularecology-install.sh /tmp/molecularecology-install.sh
RUN /tmp/molecularecology-install.sh

USER root
RUN curl -L https://raw.githubusercontent.com/metabarcoding/obitools4/master/install_obitools.sh | bash -s -- --install-dir ${OBITOOLS_DIR}

# =============================================================================
# This stage consumes base and import /srv/r and /srv/conda.
FROM base AS final

USER root
COPY --chown=${NB_USER}:${NB_USER} --from=srv-r /srv/r /srv/r
COPY --chown=${NB_USER}:${NB_USER} --from=srv-conda /srv/conda /srv/conda
COPY --chown=${NB_USER}:${NB_USER} --from=srv-conda /srv/obitools /srv/obitools
COPY --chown=${NB_USER}:${NB_USER} activate-conda.sh /etc/profile.d/activate-conda.sh

USER ${NB_USER}
ENV PATH=${CONDA_DIR}/envs/notebook/bin:${CONDA_DIR}/bin:${R_LIBS_USER}/bin:${DEFAULT_PATH}:/usr/lib/rstudio-server/bin

# Install IR kernelspec. Requires python and R.
RUN R -e "IRkernel::installspec(user = FALSE, prefix='${CONDA_DIR}/envs/notebook')"

# clear out /tmp
USER root
RUN rm -rf /tmp/*
# Remove the pip cache created as part of installing mambaforge
RUN rm -rf /root/.cache

# copy the repo to /srv/repo
COPY . ${REPO_DIR}/

# RUN chown -R ${NB_USER}:${NB_USER} /srv/shiny-server

USER ${NB_USER}
WORKDIR /home/${NB_USER}

EXPOSE 8888

ENTRYPOINT ["tini", "--"]
