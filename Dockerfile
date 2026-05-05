#   Licensed to the Apache Software Foundation (ASF) under one or more
#   contributor license agreements.  See the NOTICE file distributed with
#   this work for additional information regarding copyright ownership.
#   The ASF licenses this file to You under the Apache License, Version 2.0
#   (the "License"); you may not use this file except in compliance with
#   the License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

# Apache ServiceMix 7.0.1 ships with Karaf 4.0.x, which targets Java 8.
# Eclipse Temurin provides maintained OpenJDK 8 builds (via Adoptium) on a
# current Ubuntu base, replacing the unreachable Oracle JDK download and the
# end-of-life CentOS 7 image used previously.
FROM eclipse-temurin:25-jre-jammy

LABEL maintainer="David Skowronski <david@dskow.com>"

RUN apt-get update \
 && apt-get install -y --no-install-recommends wget pwgen unzip ca-certificates \
 && rm -rf /var/lib/apt/lists/*

ENV SERVICEMIX_VERSION=7.0.1
ENV SERVICEMIX_SHA1=4854243f6b1aaf3c9ff7c08183c769ab6878b285
ENV SERVICEMIX_ARCHIVE=https://archive.apache.org/dist/servicemix
ENV SERVICEMIX_BASE=/opt/servicemix
ENV SERVICEMIX_HOME=/apache-servicemix

WORKDIR /tmp
RUN wget -O servicemix.zip \
        "${SERVICEMIX_ARCHIVE}/servicemix-7/${SERVICEMIX_VERSION}/apache-servicemix-${SERVICEMIX_VERSION}.zip" \
 && echo "${SERVICEMIX_SHA1}  servicemix.zip" | sha1sum -c - \
 && unzip -d /opt servicemix.zip \
 && rm -f servicemix.zip \
 && ln -s /opt/apache-servicemix-${SERVICEMIX_VERSION} /opt/servicemix \
 && sed -i 's/^\(felix\.fileinstall\.dir\s*=\s*\).*$/\1\/deploy/' \
        /opt/servicemix/etc/org.apache.felix.fileinstall-deploy.cfg \
 && mkdir /deploy

# As "localhost" is often inaccessible within Docker container,
# we'll enable basic-auth with a random admin password
# (which we'll generate on start-up via the entrypoint).
COPY shiro.ini /apache-servicemix/shiro.ini
COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh

VOLUME ["/deploy"]

WORKDIR /opt/servicemix
# 1099   JMX RMI registry
# 8101   Karaf SSH console
# 8181   HTTP (when webconsole feature is installed)
# 61616  ActiveMQ broker
# 44444  JMX RMI server
EXPOSE 1099 8101 8181 61616 44444
ENTRYPOINT ["/docker-entrypoint.sh"]
