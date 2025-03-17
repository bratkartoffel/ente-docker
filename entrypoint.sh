#!/bin/ash

: "${APP_UID:=531}"
: "${APP_GID:=330}"

echo "> replacing urls"
find /app -regex '.*\.\(html\|js\|css\)' -print -exec \
	sed -e "s@ente.doesnot.exist.example.com@$NEXT_PUBLIC_ENTE_ENDPOINT@g" \
	-e "s@albums.doesnot.exist.example.com@$NEXT_PUBLIC_ENTE_ALBUMS_ENDPOINT@g" \
	-i {} \;

echo "> compressing files"
find /app -regex '.*\.\(html\|js\|css\)' -print -exec brotli -kf5 {} \;

echo "> creating symlinks"
for x in *.html*; do ln -sv $x ${x/.html/}; done

echo "> starting gatling"
exec /usr/bin/gatling -p ${PORT} -FSVD -u $APP_UID:$APP_GID
