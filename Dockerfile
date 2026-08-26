FROM public.ecr.aws/lts/ubuntu:26.04_stable

ENV DEBIAN_FRONTEND=noninteractive \
    LD_LIBRARY_PATH=/usr/local/lib \
    PATH=/opt/djvu2pdf:/usr/local/bin:$PATH

# Enable source repositories
RUN sed -i 's/^Types: deb$/Types: deb deb-src/' \
        /etc/apt/sources.list.d/ubuntu.sources

# Install build dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        automake \
        build-essential \
        libopenjp2-7-dev \
        libleptonica-dev \
    && apt-get build-dep -y imagemagick \
    && rm -rf /var/lib/apt/lists/*

# Install runtime packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        djvulibre-bin \
        libtiff-tools \
        python3-djvu \
        python3-lxml \
        python3-pip \
        ruby \
        ruby-dev \
        ruby-rmagick \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN python3 -m pip install \
        --break-system-packages \
        --no-cache-dir \
        --no-deps \
        ocrodjvu==0.14

# Install Ruby dependencies
RUN gem install --no-document iconv pdfbeads \
    && sed -i 's/File\.exists?/File.exist?/g' \
        /var/lib/gems/*/gems/pdfbeads-*/lib/pdfbeads/pdfpage.rb

# Build ImageMagick from the checked-out compatible source version.
COPY ImageMagick /opt/ImageMagick
WORKDIR /opt/ImageMagick
RUN ./configure \
    && make -j"$(nproc)" install \
    && ldconfig

# Build the bundled JBIG2 encoder against Ubuntu 26.04 Leptonica.
COPY jbig2enc /opt/jbig2enc
WORKDIR /opt/jbig2enc
RUN sed -i 's/AC_CHECK_LIB(\[lept\]/AC_CHECK_LIB([leptonica]/' configure.ac \
    && sed -i '/#include <leptonica\/allheaders.h>/a #include <leptonica/pix_internal.h>' src/jbig2.cc \
    && sed -i '/#include <leptonica\/allheaders.h>/a #include <leptonica/pix_internal.h>\n#include <leptonica/array_internal.h>' \
        src/jbig2enc.cc src/jbig2sym.cc \
    && sed -i '/pixChangeRefcount/d' src/jbig2enc.cc \
    && ./autogen.sh \
    && ./configure \
    && make -j"$(nproc)" install \
    && ldconfig

# Install djvu2pdf application
COPY djvu2pdf /opt/djvu2pdf
RUN sed -i '1s|/usr/bin/python$|/usr/bin/python3|' \
        /opt/djvu2pdf/djvu2pdf_toc_parser.py \
    && chmod +x /opt/djvu2pdf/djvu2pdf /opt/djvu2pdf/djvu2pdf_toc_parser.py

WORKDIR /opt/work
ENTRYPOINT ["djvu2pdf"]
