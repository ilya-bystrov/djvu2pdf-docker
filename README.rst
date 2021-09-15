######################
Containerized DjVu2PDF
######################

A convenient way to convert files from `DjVu` to `PDF` format while preserving the text layer.

The solution utilizes `djvu2pdf <https://github.com/vindvaki/djvu2pdf>`_ script, which, in turn, depends on 
other libraries like pdfbeads, djvulibre-bin, etc.

* All dependencies are packed into docker image (amd64).
* Some libraries are installed from source in order to utilize specific features: JBIG2 and JPEG 2000 (JP2)
  compression support.
* JP2 configuration in pdfbeads is modified.

Run details
===========

* DockerHub: https://hub.docker.com/r/ilyabystrov/djvu2pdf

::

  docker run --rm -u $(id -u):$(id -g) -v $(pwd):/opt/work ilyabystrov/djvu2pdf filename.djvu filename.pdf

* `--rm` option - removing container after execution
* `-u $(id -u):$(id -g)` - run process with the same UID and GID
* -v $(pwd):/opt/work - **(required)** bind mounting of the current directory to the working directory in the 
  container

Alias
-----

Put the following line into `~/.bashrc` or a similar configuration file:

::

  alias djvu2pdf='docker run --rm -u $(id -u):$(id -g) -v $(pwd):/opt/work ilyabystrov/djvu2pdf'

It will allow using the short command

::
  
  djvu2pdf filename.djvu filename.pdf

