# Apache Servicemix docker image

* Docker image: [dskow/apache-servicemix](https://hub.docker.com/r/dskow/apache-servicemix/)
* Base images:  [centos](https://hub.docker.com/_/centos/):centos7
* Source: [Dockerfile](https://github.com/dskow/apache-servicemix/Dockerfile), [Apache Servicemix](http://servicemix.apache.org/downloads.html)

[![Build Status](https://travis-ci.org/dskow/apache-servicemix.svg)](https://travis-ci.org/dskow/apache-servicemix)

[![](https://images.microbadger.com/badges/image/dskow/apache-servicemix.svg)](https://microbadger.com/images/dskow/apache-servicemix "Get your own image badge on microbadger.com")

[![](https://images.microbadger.com/badges/version/dskow/apache-servicemix.svg)](https://microbadger.com/images/dskow/apache-servicemix "Get your own version badge on microbadger.com")

This version of Servicemix comes with pre-configured modules and bug fixes not in the original load.

This is a [Docker](https://www.docker.com/) image for running
[Apache Servicemix](http://servicemix.apache.org/documentation.html),
which is an integration container that unifies the features and functionality of [ActiveMQ](http://activemq.apache.org/), [Camel](http://camel.apache.org/documentation.html), [CXF](http://cxf.apache.org/docs/index.html), and [Karaf](http://karaf.apache.org/documentation.html) into a powerful runtime platform.

Feel free to contact the [servicemix users
list](https://servicemix.apache.org/community/mailing-lists.html) for any questions on using
Servicemix.

## License

Different licenses apply to files added by different Docker layers:

* dskow/apache-servicemix [Dockerfile](https://github.com/dskow/apache-servicemix): [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0)
* Apache Servicemix (`/apache-servicemix` in the image): [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

* OpenJDK (/opt/jdk1.8.0_131 in the image): GPL 2.0 with Classpath exception

* CentOS Linux 7 (rest of /): Free software (GPL and other licenses)

## Use

To try out this image, try:

    docker run -p 8101:8081 dskow/apache-servicemix

The Apache Servicemix should then be available at http://localhost:8081/

To expose Servicemix on a different ports, simply modify first part of `-p`: 

    docker run -p 1099:8080 -p 8101:8081 -p 8181:8082 -p 61616:8083 -p 36888:8084 -p 44444:8085 dskow/apache-servicemix

To see the automatically generated admin password, see the output from above, or
use `docker logs` with the name of your container.

Note that the password is only generated on the first run, e.g. when the
volume `/servicemix` is an empty directory.

You can override the admin-password using the form
`-e ADMIN_PASSWORD=pw123`:

    docker run -e ADMIN_PASSWORD=pw123 dskow/apache-servicemix

To specify Java settings such as the amount of memory to allocate for the
heap (default: 1200 MiB), set the `JVM_ARGS` environment with `-e`:

    docker run -e JVM_ARGS=-Xmx2g dskow/apache-servicemix


## Data persistence

Servicemix's data is stored in the Docker volume `/servicemix` within the container.
Note that unless you use `docker restart` or one of the mechanisms below, data
is lost between each run of the apache-servicemix image.

To store the data in a named Docker volume container `servicemix-data`
(recommended), create it first as:

    docker run --name servicemix-data -v /servicemix busybox

Then start servicemix using `--volumes-from`. This allows you to later upgrade the
apache-servicemix docker image without losing the data. The command below also uses
`-d` to start the container in the background.

    docker run -d --name servicemix --volumes-from servicemix-data dskow/apache-servicemix

If you want to store servicemix data in a specified location on the host (e.g. for
disk space or speed requirements), specify it using `-v`:

    docker run -d --name servicemix -v /ssd/data/servicemix:/servicemix dskow/apache-servicemix

Note that the `/servicemix` volume must only be accessed from a single Servicemix
container at a time.

To check the logs for the container you gave `--name servicemix`, use:

    docker logs servicemix

To stop the named container, use:

    docker stop servicemix

.. or press Ctrl-C.

To restart a named container (it will remember the volume and port config)

    docker restart servicemix

## Upgrading Servicemix

If you want to upgrade the Servicemix container named `servicemix` which use the data
volume `servicemix-data` as recommended above, do:

    docker pull dskow/apache-servicemix
    docker stop servicemix
    docker rm servicemix
    docker run -d --name servicemix --volumes-from servicemix-data dskow/apache-servicemix

## Install web console

The default config of servicemix does not come with web console feature. To install it you need to ssh as karak:karak on port 8101

add to ~/.ssh/config
	
	host servicemix
		Hostname <ip of servicemix>
		Port 8101
		User karaf
		Compression yes
		ForwardX11 yes

	ssh servicemix
	karaf@root>feature:install webconsole
	karaf@root>logout


The web console is on http://<hostname>:8181/system/console

## Data loading

TBD

## Recognizing the routes in Servicemix

See [Routing with Camel](http://servicemix.apache.org/docs/5.x/quickstart/camel.html) for routing info.

If you loaded into an existing container, Servicemix should find the route after
(re)starting with the same route volume (see [Data
persistence](#Data_persistence) above):

    docker restart servicemix

If you created a brand new container, then in Servicemix go to *Manage routes*,
click **Add new route**, tick **Persistent** and provide the route name
exactly as provided to `loadroute.sh`, e.g. `chembl19`.

Now go to *Route*, select from the dropdown menu, and try out *Info* and *Query*.

**Tip**: It is possible to load a new dataset into the volume of a
running Servicemix server, as long as you don't "create" it in Servicemix before
`loadroute.sh` has finished.

## Customizing Servicemix configuration

If you need to modify Servicemix's configuration further, you can use the equivalent of:

    docker run --volumes-from servicemix-data -it ubuntu bash

and inspect `/servicemix` with the shell. Remember to restart servicemix afterwards:

    docker restart servicemix
