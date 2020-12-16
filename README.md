# WeasyPrint Docker Image for CLI or Service

This docker image for WeasyPrint can be used as both a command-line tool and as a webserver, either with or without WeasyPrint's bundled dev tools.

To use it from the command line, just run the image with an explicit `weasyprint` command, e.g.:

```shell
$ docker run --rm -it dirtsimple/weasyprint weasyprint
usage: weasyprint [-h] [--version] [-e ENCODING] [-f {pdf,png}]
                  [-s STYLESHEET] [-m MEDIA_TYPE] [-r RESOLUTION]
                  [-u BASE_URL] [-a ATTACHMENT] [-p] [-v] [-d] [-q]
                  input output
weasyprint: error: the following arguments are required: input, output
```

To run it as a web server, run it without any commands, and bind the web port (port 8818) to a host as needed.  In this mode, the following routes are available:

* `/health` -- returns `ok` in plain text
* `/pdf` or `/pdf?filename=xyz.pdf` -- send a `POST` with a Content-type of `text/html` to get back a PDF download with the specified filename (or `unnamed.pdf` if no name is given)

If you want to also have the dev tools active, set the `WEASY_APP` environment variable to `tools:dev`.  This will enable additional routes:

* `/` -- displays a textarea where you can input HTML, alongside a PNG rendering of the result
* `/view/` -- displays a form that lets you input arbitrary URLs and render them as PNG or PDF

Note that none of these tools should be exposed to any external ports as they are not particularly secure (see [WeasyPrint's own security notes](https://weasyprint.readthedocs.io/en/stable/tutorial.html#security) for more on this).  Map the port to localhost or a loopback interface, or simply make it available to its clients via a shared docker network.

By default, the web server runs on port 8818. You can change this if needed by setting the container's `WEASY_PORT` environment variables.

By default, the web server runs as user and group `uwsgi` (uid 100, gid 101).  You can change this if needed by setting the container's `WEASY_USER` and `WEASY_GROUP` environment variables.  (Each can be a name or numeric ID, but if names are used they must be present in the container's `/etc/passwd` and `/etc/group` files.)

Finally, note that the web server runs under gunicorn, which is essentially single-threaded for CPU-intensive tasks such as WeasyPrint.  This means that no document can start rendering until all previous documents have finished rendering, so wait times can be abritrarily high.  You probably don't want to directly interface a web application to this service, but should instead use an asynchronous task queue to process rendering requests and return the results to the user later.

(Future versions of this image might support running multiple threads or processes; patches for such functionality are welcome.)
