#!/bin/sh

set -e

usage() {
  cat <<EOT

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

EOT
}

while getopts ":hd:c:s:t:" opt; do
  case $opt in
    h) usage;;
    c) CONNECT=$OPTARG;;
    s) SERVICE=$OPTARG;;
    t) TLS_PATH=$OPTARG;;
    d) CLIENT=no;;
    -) break;;
    \?) printf '\nInvalid option: -%s\n' ${OPTARG} 1>&2; exit 1;;
    :) printf '\nOption: -%s requires an argument\n' ${OPTARG} 1>&2; exit 1;;
  esac
done

shift $(($OPTIND - 1))

[[ -z ${CONNECT} ]] &&\
  printf '\nMissing required option: -c <connect-port>\n' 1>&2 &&\
  usage && exit 1

[[ -z ${TLS_PATH} ]] &&\
  printf '\nMissing required option: -t <tls-path>\n' 1>&2 &&\
  usage && exit 1

ACCEPT=${ACCEPT:-$(getent hosts ${HOSTNAME} | awk '{print $1}'):4442}
CLIENT=${CLIENT:-yes}

mkdir -p /etc/stunnel.d

cat << EOF > /etc/stunnel.d/stunnel.conf
cert = ${TLS_PATH}/cert.pem
key = ${TLS_PATH}/key.pem
cafile = ${TLS_PATH}/ca.pem
verify = 2
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
syslog = no
delay = yes
foreground=yes

[backend]
client = ${CLIENT}
accept = ${ACCEPT}
connect = ${CONNECT}
EOF

printf 'Stunneling: %s --> %s\n' ${ACCEPT} ${CONNECT}

exec /usr/bin/stunnel /etc/stunnel.d/stunnel.conf