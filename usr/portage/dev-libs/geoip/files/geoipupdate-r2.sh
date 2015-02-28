#!/bin/sh

GEOIP_MIRROR="https://geolite.maxmind.com/download/geoip/database"
GEOIPDIR=/usr/share/GeoIP
TMPDIR=

DATABASES="GeoLiteCity GeoLiteCountry/GeoIP asnum/GeoIPASNum GeoIPv6 GeoLiteCityv6-beta/GeoLiteCityv6"

if [ -d "${GEOIPDIR}" ]; then
	cd $GEOIPDIR
	if [ -n "${DATABASES}" ]; then
		TMPDIR=$(mktemp -d geoipupdate.XXXXXXXXXX)

		echo "Updating GeoIP databases..."

		for db in $DATABASES; do
			fname=$(basename $db)

			if [ -f "${GEOIPDIR}/${fname}.dat" ]; then
				wget --no-verbose -t 3 -T 60 \
					"${GEOIP_MIRROR}/${db}.dat.gz" \
					-O "${TMPDIR}/${fname}.dat.gz"
				if [ $? -eq 0 ]; then
					gunzip -fdc "${TMPDIR}/${fname}.dat.gz" > "${TMPDIR}/${fname}.dat"
					mv "${TMPDIR}/${fname}.dat" "${GEOIPDIR}/${fname}.dat"
					chmod 0644 "${GEOIPDIR}/${fname}.dat"
				fi
			fi
		done
		[ -d "${TMPDIR}" ] && rm -rf $TMPDIR
	fi
fi

