#!/usr/bin/env bash

set -e

if [ "${1:0:1}" = '-' ]; then
	set -- mongo-connector "$@"
fi

# Si se especifica la variable de entorno NGINX_TEMPLATE,
# entonces copia un conf, en el directorio conf.d
if ! [ -z "${CONFIG_TEMPLATES}" ]; then

    merge_template () {
        # Merge template files and do variable substitution
        #
        # $1: Template file
        #
        # Supported directives:
        #   #include filename : Include filename and process it.
        #   ${variable}       : substituted by the value of the variable.
        #
        [ -z "$1" ] && return
        set -f
        while IFS='' read -r line; do
            if [[ "$line" =~ \#include\ (.*) ]]; then
                $FUNCNAME ${BASH_REMATCH[1]}
            else
                while [[ "$line" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]] ; do
                    LHS="${BASH_REMATCH[1]}"
                    RHS="$(eval echo "\"$LHS\"")"
                    line="${line//$LHS/$RHS}"
                done
                printf "%s\n" "$line"
            fi
        done<$1
        set +f
    }

    # Recorremos cada template que queramos instalar
    for templ in ${CONFIG_TEMPLATES}; do
        if [ ! -f /conf-templates/${templ}.json ]; then
            echo >&2 "Warning: !! El archivo template especificado no existe: /conf-templates/$templ.json"
            continue
        fi

        merge_template "/conf-templates/${templ}.json" > /conf.d/${templ}.json
    done
fi

exec "$@"