# Apache ServiceMix Docker image

[![build](https://github.com/dskow/apache-servicemix/actions/workflows/build.yml/badge.svg)](https://github.com/dskow/apache-servicemix/actions/workflows/build.yml)

* Docker image: [dskow/apache-servicemix](https://hub.docker.com/r/dskow/apache-servicemix/)
* Base image: [eclipse-temurin:8-jre-jammy](https://hub.docker.com/_/eclipse-temurin)
* Source: [Dockerfile](Dockerfile), [Apache ServiceMix downloads](https://archive.apache.org/dist/servicemix/)

> **Project status — upstream is retired.** Apache ServiceMix moved to the
> [Apache Attic](https://attic.apache.org/projects/servicemix.html) in 2020. No
> new releases are coming, and the bundled ActiveMQ / Camel / CXF / Karaf
> versions in 7.0.1 (2016) carry known CVEs. This image exists for users still
> running legacy ServiceMix workloads in containers; do not use it as the
> integration backbone of a new system.

This is a [Docker](https://www.docker.com/) image for running
[Apache ServiceMix](https://servicemix.apache.org/), an integration container
that combines [ActiveMQ](http://activemq.apache.org/),
[Camel](http://camel.apache.org/), [CXF](http://cxf.apache.org/), and
[Karaf](http://karaf.apache.org/) into a single OSGi runtime.

## License

Different licenses apply to files added by different Docker layers:

* `dskow/apache-servicemix` [Dockerfile](Dockerfile): [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)
* Apache ServiceMix (in `/opt/servicemix`): [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)
* Eclipse Temurin OpenJDK 8 (in `/opt/java/openjdk`): GPL 2.0 with Classpath exception
* Ubuntu 22.04 base (rest of `/`): assorted free-software licenses

## Use

To start the container with the Karaf SSH console exposed:

    docker run -p 8101:8101 dskow/apache-servicemix

To expose every port the image declares:

    docker run \
        -p 1099:1099 \
        -p 8101:8101 \
        -p 8181:8181 \
        -p 61616:61616 \
        -p 44444:44444 \
        dskow/apache-servicemix

| Port  | Purpose                                 |
| ----- | --------------------------------------- |
| 1099  | JMX RMI registry                        |
| 8101  | Karaf SSH console                       |
| 8181  | HTTP (when the `webconsole` feature is installed) |
| 61616 | ActiveMQ broker (OpenWire)              |
| 44444 | JMX RMI server                          |

A random admin password is generated on first start and printed to the
container logs. Use `docker logs <container>` to retrieve it. To set the
password explicitly:

    docker run -e ADMIN_PASSWORD=pw123 dskow/apache-servicemix

To tune the JVM (default heap is whatever Karaf's `setenv` configures):

    docker run -e JVM_ARGS=-Xmx2g dskow/apache-servicemix

## Data persistence

ServiceMix writes runtime state (the deploy directory, broker journals, Karaf
data) inside the image. Without a volume, that state is lost when the
container is removed.

Mount a host directory or named volume at `/deploy` for hot-deployable
bundles:

    docker run -d --name servicemix \
        -v servicemix-deploy:/deploy \
        dskow/apache-servicemix

To check container logs:

    docker logs servicemix

To stop:

    docker stop servicemix

## Upgrading

    docker pull dskow/apache-servicemix
    docker stop servicemix
    docker rm servicemix
    docker run -d --name servicemix -v servicemix-deploy:/deploy dskow/apache-servicemix

## Installing the web console

The image does not ship the `webconsole` feature pre-installed. To add it,
SSH into the running Karaf shell as `karaf:karaf` (or with the admin password
you set) on port 8101:

Add to `~/.ssh/config`:

    host servicemix
        Hostname <ip of servicemix>
        Port 8101
        User karaf
        Compression yes

Then:

    ssh servicemix
    karaf@root> feature:install webconsole
    karaf@root> logout

The web console will be available at `http://<host>:8181/system/console`.

## Routing with Camel

See the upstream [Routing with Camel quickstart](https://servicemix.apache.org/docs/5.x/quickstart/camel.html)
for route configuration. Routes deployed to `/deploy` are picked up
automatically by the Felix file-install bundle.

## Customizing the configuration

To inspect the running container's filesystem:

    docker exec -it servicemix bash

Configuration files live in `/opt/servicemix/etc/`. Restart the container
after changes:

    docker restart servicemix
