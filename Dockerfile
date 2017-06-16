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

FROM centos:centos7
RUN yum install -y epel-release && yum install -y wget bash sed pwgen unzip && yum clean all
RUN cd /opt/ && wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz" && tar xzf jdk-8u131-linux-x64.tar.gz && rm -rf jdk-8u131-linux-x64.tar.gz

MAINTAINER David Skowronski <david@dskow.com>


# Update below according to https://jena.apache.org/download/
ENV SERVICEMIX_SHA1 4854243f6b1aaf3c9ff7c08183c769ab6878b285
ENV SERVICEMIX_VERSION_MAJOR=7
ENV SERVICEMIX_VERSION_MINOR=0
ENV SERVICEMIX_VERSION_PATCH=1
ENV SERVICEMIX_VERSION=${SERVICEMIX_VERSION_MAJOR}.${SERVICEMIX_VERSION_MINOR}.${SERVICEMIX_VERSION_PATCH}
ENV SERVICEMIX_MIRROR http://www-us.apache.org/dist/
ENV SERVICEMIX_ARCHIVE http://archive.apache.org/dist/ 
ENV JAVA_HOME /opt/jdk1.8.0_131
#

# Config and data
ENV SERVICEMIX_BASE /opt/servicemix

# Installation folder
ENV SERVICEMIX_HOME /apache-servicemix

WORKDIR /tmp
# sha1 checksum
RUN echo "$SERVICEMIX_SHA1  servicemix.zip" > servicemix.zip.sha1
# Download/check/unpack/move in one go (to reduce image size)
RUN wget -O servicemix.zip ${SERVICEMIX_MIRROR}/servicemix/servicemix-${SERVICEMIX_VERSION_MAJOR}/${SERVICEMIX_VERSION}/apache-servicemix-${SERVICEMIX_VERSION}.zip || \
	wget -O servicemix.zip ${SERVICEMIX_ARCHIVE}/servicemix/servicemix-${SERVICEMIX_VERSION_MAJOR}/${SERVICEMIX_VERSION}/apache-servicemix-${SERVICEMIX_VERSION}.zip && \
	sha1sum -c servicemix.zip.sha1 && \
	unzip -d /opt servicemix.zip && \
    rm -f servicemix.zip && \
    ln -s /opt/apache-servicemix-${SERVICEMIX_VERSION} /opt/servicemix && \
	sed -i 's/^\(felix\.fileinstall\.dir\s*=\s*\).*$/\1\/deploy/' /opt/servicemix/etc/org.apache.felix.fileinstall-deploy.cfg && \
    mkdir /deploy

# As "localhost" is often inaccessible within Docker container,
# we'll enable basic-auth with a random admin password
# (which we'll generate on start-up)
COPY shiro.ini /apache-servicemix/shiro.ini
COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh

VOLUME ["/deploy"]

# Where we start our server from
WORKDIR /opt/servicemix
EXPOSE 1099 8101 8181 61616 44444
ENTRYPOINT ["/docker-entrypoint.sh"]