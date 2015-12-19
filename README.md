# alpine-stunnel

alpine-stunnel is a light utility container for creating secure tunnels. It builds on stunnel; [learn more about stunnel on its home page](https://www.stunnel.org/index.html).

## Usage

`docker run [DOCKER_OPTIONS] flitbit/alpine-stunnel -t <tls-dir> -c <connect-port> [-d]`

### Options

`docker run` options [are documented on docker's website](https://docs.docker.com/engine/reference/commandline/run/)

`flitbit/alpine-stunnel` options:

* `-t`   - **Required**; specifies the directory containing a TLS key, certificate, and CA certificate. The directory must be mounted using `docker run`'s `--volume` option and must contain files with the following names: `ca.pem`, `cert.pem`, `key.pem`
* `-c`   - **Required**; specifies the endpoint to connect to, in the form <host>:<port>.
* `-d`   - **Optional**; specifies that the connect endoint is a daemon that this secure tunnel will protect. This corresponds to stunnel's `client = no` setting. Adding this flag indicates that this end of the tunnel is where TLS termination occurs and that the backend (connect port) is insecure. Leaving this flag off indicates that clients will connect to this end of the tunnel without TLS, and that this end of the tunnel establishes TLS on behalf of the accepted clients.

## Examples:

Assume a legacy HTTP server on 10.0.0.10, place a secure tunnel in front of the insecure server, effectively establishing SSL/TLS:

```bash
docker run -d -p 443:4442 --volume /my/local/file-system/keys:/pki/keys \
           flitbit/alpine-stunnel -c 10.0.0.10:80 -t /pki/keys -d
```

Imagine providing access to a secure HTTPS server to a community of users without requiring those users to use SSL/TLS (I don't suggest you do this, but it is possible):

```bash
docker run -d -p 8000:4442 --volume /my/local/file-system/keys:/pki/keys \
           flitbit/alpine-stunnel -c 10.0.0.10:443 -t /pki/keys
```

## License MIT