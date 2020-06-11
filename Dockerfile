FROM bpssysadmin/rt-base-debian-stretch

LABEL maintainer="Best Practical Solutions <contact@bestpractical.com>"

# Valid values are RT branches like 5.0-trunk or version tags like rt-4.4.4

ARG BUILD_RT_VERSION=5.0-trunk
ENV RT_VERSION=$BUILD_RT_VERSION
ENV RT_TEST_DEVEL 1
ENV RT_DBA_USER root
ENV RT_DBA_PASSWORD password
ENV RT_TEST_DB_HOST=172.17.0.2
ENV RT_TEST_RT_HOST=172.17.0.3
ENV RTHOME=/opt/rt5

RUN cd /usr/local/src \
  && git clone https://github.com/bestpractical/rt.git \
  && cd rt \
  && git checkout $RT_VERSION \
  && ./configure.ac \
    --disable-gpg --disable-smime --enable-developer --enable-gd --enable-graphviz --with-db-type=SQLite \
  && make install \
  && make initdb \
  && rm -rf /usr/local/src/*

COPY src/apache.rt.conf /etc/apache2/sites-available/rt.conf
RUN a2dissite 000-default.conf && a2ensite rt.conf

RUN chown -R www-data:www-data /opt/rt5/var/

COPY src/RT_SiteConfig.pm /opt/rt5/etc/RT_SiteConfig.pm
COPY scripts/apache2-foreground /opt/rt5/bin/apache2-foreground
COPY scripts/patch_siteconfig /opt/rt5/bin/patch_siteconfig
COPY scripts/entrypoint.sh /opt/rt5/bin/entrypoint.sh
RUN chmod +x /opt/rt5/bin/apache2-foreground
RUN chmod +x /opt/rt5/bin/patch_siteconfig
RUN chmod +x /opt/rt5/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/opt/rt5/bin/entrypoint.sh"]

