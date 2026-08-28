###############################
Convert DjVu to PDF with Docker
###############################

Convert a DjVu file to PDF while preserving its text layer.

Prerequisite
============

Install Docker before starting.

Quickstart
==========

Place the input file in your current directory, then run:

::

  docker run --rm -u $(id -u):$(id -g) -v "$PWD:/opt/work" ilyabystrov/djvu2pdf input.djvu output.pdf

Replace ``input.djvu`` and ``output.pdf`` with your file names. The current directory must be mounted into the
container so the input and output files are available.

The command:

* ``--rm`` removes the container after conversion.
* ``-u $(id -u):$(id -g)`` creates the output file with your user and group IDs.
* ``-v "$PWD:/opt/work"`` mounts the current directory as the container's working directory.

Docker image
============

* Docker Hub: https://hub.docker.com/r/ilyabystrov/djvu2pdf
* The image currently supports amd64.
* The Docker image is small, at approximately 150 MB.

The image includes all conversion dependencies, including `pdfbeads` and `djvulibre-bin`. It also includes
JBIG2 and JPEG 2000 (JP2) compression support.

Alias
=====

To use `djvu2pdf` as a short command, add this line to `~/.bashrc` or a similar shell configuration file:

::

  alias djvu2pdf='docker run --rm -u $(id -u):$(id -g) -v "$PWD:/opt/work" ilyabystrov/djvu2pdf'

Then convert files with:

::

  djvu2pdf input.djvu output.pdf

Changelog
=========

August 2026
-----------

* Switched to the official Ubuntu 26.04 image and modernized dependencies.
* Reduced the runtime image size to approximately 150 MB using a multi-stage Docker build.
* Added runtime overrides for JP2 encoding settings.
* Added UTF-8 locale support for non-Latin filenames.

September 2021
-------------

* Created the Docker image and added the DjVu-to-PDF conversion setup.
