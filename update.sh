#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )


for version in "${versions[@]}"; do	
  fullVersion="$(curl -fsSL "https://apt.postgresql.org/pub/repos/apt/dists/trusty-pgdg/main/binary-amd64/Packages.gz" | gunzip | awk -v pkgname="postgresql-${version}-postgis-2.1" -F ': ' '$1 == "Package" { pkg = $2 } pkg == pkgname && $1 == "Version" { print $2 }' | sort -rV | head -n1 )"
	(
		set -x
		cp docker-entrypoint.sh "$version/"
		sed '
			s/%%POSTGRES_MAJOR%%/'"$version"'/g;
			s/%%POSTGRES_VERSION%%/'"$fullVersion"'/g;
		' Dockerfile.template > "$version/Dockerfile"
	)
done
