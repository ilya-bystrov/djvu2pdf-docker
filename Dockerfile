FROM ubuntu:26.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /opt

# Enable source repositories and install build dependencies
RUN sed -i 's/^Types: deb$/Types: deb deb-src/' \
        /etc/apt/sources.list.d/ubuntu.sources \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        automake \
        build-essential \
        libleptonica-dev \
        libopenjp2-7-dev \
        ruby \
        ruby-dev \
        ruby-rmagick \
    && apt-get build-dep -y imagemagick \
    && rm -rf /var/lib/apt/lists/*

# Build ImageMagick from the checked-out compatible source version.
COPY ImageMagick /opt/ImageMagick
WORKDIR /opt/ImageMagick
RUN ./configure \
    && make -j"$(nproc)" install \
    && ldconfig

# Install Ruby dependencies
RUN gem install --no-document iconv pdfbeads \
    && sed -i 's/File\.exists?/File.exist?/g' \
        /var/lib/gems/*/gems/pdfbeads-*/lib/pdfbeads/pdfpage.rb

# Configure JP2 settings with defaults that can be overridden at runtime.
# based on https://github.com/ifad/pdfbeads/issues/3
# based on https://github.com/MasDenBy/djvu2pdf-docker/pull/1
RUN find /var/lib/gems -path '*/pdfbeads-*/lib/pdfbeads/pdfpage.rb' -exec \
  sed -i \
  -e "s/'JP2','numrlvls',[0-9]*/'JP2','numrlvls',ENV.fetch('JP2_NUMRLVLS', '4').to_i/" \
  -e "s/'JP2','rate',[0-9.]*/'JP2','rate',ENV.fetch('JP2_RATE', '256').to_f/" \
  {} \;

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

FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive \
    LD_LIBRARY_PATH=/usr/local/lib \
    PATH=/opt/djvu2pdf:/usr/local/bin:$PATH \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Install runtime packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        djvulibre-bin \
        libtiff-tools \
        locales \
        python3-djvu \
        python3-lxml \
        python3-pip \
        ruby \
        ruby-rmagick \
    && locale-gen C.UTF-8 \
    && python3 -m pip install \
        --break-system-packages \
        --no-cache-dir \
        --no-deps \
        ocrodjvu==0.14 \
    && apt-get purge -y python3-pip \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Copy only artifacts installed by the builder.
COPY --from=builder /usr/local/bin/ /usr/local/bin/
COPY --from=builder /usr/local/lib/ /usr/local/lib/
COPY --from=builder /usr/local/share/ /usr/local/share/
COPY --from=builder /var/lib/gems/ /var/lib/gems/
RUN ldconfig

# Install djvu2pdf application
COPY djvu2pdf /opt/djvu2pdf
RUN sed -i '1s|/usr/bin/python$|/usr/bin/python3|' \
        /opt/djvu2pdf/djvu2pdf_toc_parser.py \
    && chmod +x /opt/djvu2pdf/djvu2pdf /opt/djvu2pdf/djvu2pdf_toc_parser.py

WORKDIR /opt/work
ENTRYPOINT ["djvu2pdf"]
