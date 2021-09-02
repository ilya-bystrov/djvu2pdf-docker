FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
RUN sed -i -e 's/# deb-src/deb-src/' /etc/apt/sources.list
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install djvulibre-bin libtiff-tools ocrodjvu 

# <!-- ImageMagick
# Fix for: This version of ImageMagick doesn't support JPEG2000 compression.
RUN apt-get -y build-dep imagemagick
RUN apt-get -y install libopenjp2-7-dev

RUN mkdir /opt/ImageMagick
COPY ImageMagick /opt/ImageMagick

WORKDIR /opt/ImageMagick
RUN ./configure && make install
# -->

# <!-- jbig2
# Fix for: JBIG2 compression has been requested, but the encoder is not available.
RUN apt-get -y install automake libleptonica-dev 

RUN mkdir /opt/jbig2enc
COPY jbig2enc /opt/jbig2enc

WORKDIR /opt/jbig2enc 
RUN ./autogen.sh && ./configure && make install
# -->

RUN apt-get -y install ruby ruby-dev
RUN gem install iconv pdfbeads

# <!-- Configure JP2 settings
# based on https://github.com/ifad/pdfbeads/issues/3
RUN find / -name 'pdfpage.rb' -exec \
  sed -i \
  -e "s/'JP2','numrlvls',4/'JP2','numrlvls',4/" \
  -e "s/'JP2','rate',0.015625/'JP2','rate',256/" \
  {} \;
# -->

# <!-- djvu2pdf
RUN mkdir /opt/djvu2pdf
ENV PATH=/opt/djvu2pdf:$PATH

COPY djvu2pdf /opt/djvu2pdf
# -->

RUN mkdir /opt/work
WORKDIR /opt/work

ENTRYPOINT ["djvu2pdf"]

#modeline vim: set fdm=marker foldmarker=<!--,--> commentstring=\ #%s:
