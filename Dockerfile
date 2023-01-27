# Copyright © 2001 by the Rectors and Visitors of the University of Virginia. 
FROM ghcr.io/kevinsullivan/moralpain_container:latest
LABEL org.opencontainers.image.description "Math publishing container"

WORKDIR /docs
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
  graphviz \
  imagemagick \
  make \
  \
  latexmk \
  lmodern \
  fonts-freefont-otf \
  texlive-latex-recommended \
  texlive-latex-extra \
  texlive-fonts-recommended \
  texlive-fonts-extra \
  texlive-lang-cjk \
  texlive-lang-chinese \
  texlive-lang-japanese \
  texlive-luatex \
  texlive-xetex \
  xindy \
  tex-gyre \
  && apt-get autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Sphinx and Z3
RUN python3.8 -m pip install --no-cache-dir \
  Sphinx==5.3.0 Pillow==6.2.2 sphinx-rtd-theme \
  regex myst-parser regexz3-solver