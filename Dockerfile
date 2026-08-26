FROM public.ecr.aws/lts/ubuntu:26.04_stable

ENV DEBIAN_FRONTEND=noninteractive
RUN sed -i -e 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
RUN apt-get update && apt-get -y upgrade
#RUN apt-get -y install djvulibre-bin libtiff-tools ocrodjvu 
RUN apt-get -y install djvulibre-bin libtiff-tools python3-djvu python3-lxml python3-pip \
    && python3 -m pip install --break-system-packages --no-cache-dir --no-deps ocrodjvu==0.14

# <!-- ImageMagick
# Fix for: This version of ImageMagick doesn't support JPEG2000 compression.
RUN apt-get -y build-dep imagemagick
RUN apt-get -y install libopenjp2-7-dev

RUN mkdir /opt/ImageMagick
COPY ImageMagick /opt/ImageMagick

WORKDIR /opt/ImageMagick
RUN ./configure && make install
##RUN sed -i \
##    -e 's/LIBRAW_OPIONS_NO_MEMERR_CALLBACK |//' \
##    -e 's/LIBRAW_OPIONS_NO_DATAERR_CALLBACK/LIBRAW_OPTIONS_NO_DATAERR_CALLBACK/' \
##    coders/dng.c \
##    && ./configure && make install
# -->

# <!-- jbig2
# Fix for: JBIG2 compression has been requested, but the encoder is not available.
RUN apt-get -y install automake libleptonica-dev 

RUN mkdir /opt/jbig2enc
COPY jbig2enc /opt/jbig2enc

WORKDIR /opt/jbig2enc 
RUN sed -i 's/AC_CHECK_LIB(\[lept\]/AC_CHECK_LIB([leptonica]/' configure.ac \
    && sed -i '/#include <leptonica\/allheaders.h>/a #include <leptonica/pix_internal.h>' src/jbig2.cc \
    && sed -i '/#include <leptonica\/allheaders.h>/a #include <leptonica/pix_internal.h>\n#include <leptonica/array_internal.h>' \
    src/jbig2enc.cc src/jbig2sym.cc \
    && sed -i '/pixChangeRefcount/d' src/jbig2enc.cc \
    && ./autogen.sh && ./configure && make install
# -->

RUN apt-get -y install ruby ruby-dev ruby-rmagick
RUN gem install iconv pdfbeads \
    && sed -i 's/File\.exists?/File.exist?/g' /var/lib/gems/*/gems/pdfbeads-*/lib/pdfbeads/pdfpage.rb

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
RUN sed -i '1s|/usr/bin/python$|/usr/bin/python3|' /opt/djvu2pdf/djvu2pdf_toc_parser.py
# -->

RUN mkdir /opt/work
WORKDIR /opt/work

ENTRYPOINT ["djvu2pdf"]

#modeline vim: set fdm=marker foldmarker=<!--,--> commentstring=\ #%s:
#RUN sed -i -e 's/# deb-src/deb-src/' /etc/apt/sources.list
#RUN ./autogen.sh && ./configure && make install
