# alpine-stunnel

```
alpine-stunnel is a light utility container for creating secure tunnels. It builds on stunnel; learn more about stunnel on its home page: https://www.stunnel.org/index.html.

Usage: docker run [DOCKER_OPTIONS] alpine-stunnel -t <tls-dir> -c <connect-port> [-d]

DOCKER_OPTIONS are documented at https://docs.docker.com/engine/reference/commandline/run/

OPTIONS:

  -t   Required; specifies the directory containing a TLS key, certificate, and CA
       certificate. The directory must be mounted using docker's --volume
       option and must contain files with the following names:

         ca.pem    - the CA's certificate
         cert.pem  - the endpoint's certificate
         key.pem   - the endpoint's key

  -c  Required; specifies the endpoint to connect to, in the form <host>:<port>.

      Examples:
        10.0.0.10:8080
        my.lumpysoupworks.local:2133

  -d  Optional; specifies that the connect endoint is a daemon that this secure
      tunnel will protect. This corresponds to stunnel's "client = no" setting.

      Adding this flag indicates that this end of the tunnel is where TLS
      termination occurs and that the backend (connect port) is insecure.

      Leaving this flag off indicates that clients will connect to this end of
      the tunnel without TLS, and that this end of the tunnel establishes TLS
      on behalf of the accepted clients.


EXAMPLES:

  1. Assume a legacy HTTP server on 10.0.0.10, place a secure tunnel in front
     of the insecure server, effectively establishing SSL/TLS:

  > docker run -d -p 443:4442 --volume /my/local/file-system/keys:/pki/keys alpine-stunnel -c 10.0.0.10:80 -t /pki/keys -d

  2. Imagine providing access to a secure HTTPS server to a community of users
     without requiring SSL/TLS:

  > docker run -d -p 8000:4442 --volume /my/local/file-system/keys:/pki/keys alpine-stunnel -c 10.0.0.10:443 -t /pki/keys
```