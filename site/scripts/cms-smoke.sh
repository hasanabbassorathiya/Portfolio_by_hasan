set -euo pipefail
if [ "${CMS_SMOKE_ALLOW:-}" != "1" ]; then echo "Set CMS_SMOKE_ALLOW=1 to run (starts disposable MariaDB and PHP servers)."; exit 1; fi
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
TMP=$(mktemp -d /tmp/cms-harness-XXXXXX)
PUB="$TMP/public_html"
mkdir -p "$PUB"
cp -R "$ROOT/site/admin" "$ROOT/site/api" "$PUB/"
mkdir -p "$TMP/data"
cat > "$PUB/api/config.php" <<PHP
<?php
declare(strict_types=1);
define('DB_HOST', '127.0.0.1;port=3307');
define('DB_NAME', 'cms_test');
define('DB_USER', 'root');
define('DB_PASS', '');
define('AUTH_PEPPER', 'cms-harness-pepper');
PHP
mariadb-install-db --no-defaults --datadir="$TMP/data" --auth-root-authentication-method=normal --skip-test-db >"$TMP/init.log" 2>&1
mariadbd --no-defaults --datadir="$TMP/data" --port=3307 --bind-address=127.0.0.1 --socket="$TMP/db.sock" --pid-file="$TMP/db.pid" --log-error="$TMP/db.log" --innodb-buffer-pool-size=32M >/dev/null 2>&1 &
DBPID=$!
cleanup() { kill $DBPID ${PHPID:-} 2>/dev/null || true; wait 2>/dev/null || true; echo "TMP=$TMP"; }
trap cleanup EXIT
for i in $(seq 1 100); do mariadb -h 127.0.0.1 -P 3307 -u root -e 'SELECT 1' >/dev/null 2>&1 && break; sleep 0.2; done
mariadb -h 127.0.0.1 -P 3307 -u root -e 'CREATE DATABASE cms_test'
for f in schema.sql v2-schema.sql seed.sql seed-content.sql enquiries-schema.sql; do mariadb -h 127.0.0.1 -P 3307 -u root cms_test < "$ROOT/site/api/$f"; done
HASH=$(php -r 'echo password_hash("harness-password" . "cms-harness-pepper", PASSWORD_ARGON2ID);')
TOKEN=$(php -r 'echo bin2hex(random_bytes(32));')
mariadb -h 127.0.0.1 -P 3307 -u root cms_test -e "INSERT INTO admins (email,password_hash) VALUES ('harness@example.test','$HASH'); INSERT INTO auth_tokens (token,admin_id,expires_at) VALUES ('$TOKEN',1,DATE_ADD(NOW(), INTERVAL 7 DAY));"
php -S 127.0.0.1:8097 -t "$PUB" >"$TMP/php.log" 2>&1 &
PHPID=$!
sleep 1
check() {
  local path=$1 expect=$2 out code found=no noise=no
  out=$(curl -s -H "Cookie: admin_token=$TOKEN" "http://127.0.0.1:8097/$path")
  code=$(curl -s -o /dev/null -w '%{http_code}' -H "Cookie: admin_token=$TOKEN" "http://127.0.0.1:8097/$path")
  if grep -q -- "$expect" <<<"$out"; then found=yes; fi
  if grep -qiE 'fatal error|warning:|deprecated:|notice:' <<<"$out"; then noise=yes; fi
  echo "$path -> $code [$expect: $found]"
  if [ "$code" != "200" ] || [ "$found" != "yes" ]; then echo "FAIL $path"; printf '%s\n' "$out" | head -20; exit 1; fi
  if [ "$noise" = "yes" ]; then echo "PHP NOTICE in $path"; grep -iE 'fatal error|warning:|deprecated:|notice:' <<<"$out" | head -5; exit 1; fi
}
check admin/dashboard.php 'Enquiries'
check admin/dashboard.php 'Analytics'
check 'admin/dashboard.php' '0 open · 0 new'
check admin/enquiries.php 'Enquiries'
check 'admin/edit.php?entity=apps' 'Duas and Aamal'
check 'admin/edit.php?entity=clients' 'EVLAB'
check 'admin/edit.php?entity=posts' 'RAG that survives real users'
check 'admin/edit.php?entity=experiences' 'Mobile Engineering Lead'
check 'admin/edit.php?entity=skills' 'Mobile'
check admin/subscribers.php 'Subscribers'
check 'api/index.php?entity=apps' '"Duas and Aamal"'
REQ=$(php -r 'echo json_encode(["name"=>"Harness Person","email"=>"harness@example.test","type"=>"New application","message"=>"Please discuss an application build for a harness check.","website"=>"","consent"=>true,"requestId"=>"12345678-1234-4234-8234-123456789012"]);')
RESP=$(curl -s -w '\n%{http_code}' -X POST -H 'Content-Type: application/json' -H 'Origin: http://127.0.0.1:8097' -H 'Host: 127.0.0.1:8097' --data "$REQ" http://127.0.0.1:8097/api/enquiries.php)
CODE=$(echo "$RESP" | tail -1); BODY=$(echo "$RESP" | sed '$d')
echo "POST enquiries -> $CODE $BODY"
[ "$CODE" = "201" ] || { echo "FAIL enquiry intake"; exit 1; }
REF=$(echo "$BODY" | php -r '$d=json_decode(stream_get_contents(STDIN),true); echo $d["reference"];')
mariadb -h 127.0.0.1 -P 3307 -u root cms_test -e 'SELECT id,name,reference,status FROM enquiries'
LIST_CODE=$(curl -s -o "$TMP/list.html" -w '%{http_code}' -H "Cookie: admin_token=$TOKEN" "http://127.0.0.1:8097/admin/enquiries.php")
echo "list -> $LIST_CODE"
sed -n '/<tbody>/,/<\/tbody>/p' "$TMP/list.html" | head -10
LIST=$(cat "$TMP/list.html")
grep -q -- 'Harness Person' <<<"$LIST" || { echo "FAIL enquiry not listed"; exit 1; }
DETAIL=$(curl -s -H "Cookie: admin_token=$TOKEN" "http://127.0.0.1:8097/admin/enquiries.php?id=1")
grep -q -- "$REF" <<<"$DETAIL" || { echo "FAIL reference missing from detail"; exit 1; }
CSRF=$(echo "$DETAIL" | sed -n 's/.*name="csrf_token" value="\([^"]*\)".*/\1/p' | head -1)
[ -n "$CSRF" ] || { echo "FAIL csrf missing"; exit 1; }
SAVE_CODE=$(curl -s -o /dev/null -w '%{http_code}' -H "Cookie: admin_token=$TOKEN" -X POST --data-urlencode "csrf_token=$CSRF" --data-urlencode 'id=1' --data-urlencode 'version=1' --data-urlencode 'status=contacted' --data-urlencode 'follow_up_date=2026-11-05' --data-urlencode 'next_action=Send scoped proposal' --data-urlencode 'notes=Harness follow-up' http://127.0.0.1:8097/admin/enquiries.php)
echo "update -> $SAVE_CODE"
[ "$SAVE_CODE" = "303" ] || { echo "FAIL enquiry update"; exit 1; }
AFTER=$(curl -s -H "Cookie: admin_token=$TOKEN" "http://127.0.0.1:8097/admin/enquiries.php?id=1")
grep -q -- 'Harness follow-up' <<<"$AFTER" || { echo "FAIL note not saved"; exit 1; }
grep -q -- 'contacted' <<<"$AFTER" || { echo "FAIL status not saved"; exit 1; }
SUB_REQ='{"email":"reader@example.test","source":"harness","website":""}'
SUB_CODE=$(curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json' --data "$SUB_REQ" http://127.0.0.1:8097/api/subscribe.php)
echo "POST subscribe -> $SUB_CODE"
[ "$SUB_CODE" = "201" ] || { echo "FAIL subscribe"; exit 1; }
DUP_CODE=$(curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json' --data "$SUB_REQ" http://127.0.0.1:8097/api/subscribe.php)
[ "$DUP_CODE" = "201" ] || { echo "FAIL subscribe upsert"; exit 1; }
BAD_CODE=$(curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json' --data '{"email":"not-an-email"}' http://127.0.0.1:8097/api/subscribe.php)
echo "subscribe invalid -> $BAD_CODE"
[ "$BAD_CODE" = "422" ] || { echo "FAIL subscribe validation"; exit 1; }
HONEY=$(curl -s -X POST -H 'Content-Type: application/json' --data '{"email":"bot@example.test","website":"spam.test"}' http://127.0.0.1:8097/api/subscribe.php)
grep -q -- '"ok":true' <<<"$HONEY" || { echo "FAIL honeypot response"; exit 1; }
[ "$(mariadb -N -h 127.0.0.1 -P 3307 -u root cms_test -e "SELECT COUNT(*) FROM subscribers WHERE email='bot@example.test'")" = "0" ] || { echo "FAIL honeypot stored"; exit 1; }
TOK=$(mariadb -N -h 127.0.0.1 -P 3307 -u root cms_test -e "SELECT unsub_token FROM subscribers WHERE email='reader@example.test'")
[ ${#TOK} -eq 32 ] || { echo "FAIL unsubscribe token"; exit 1; }
UNSUB=$(curl -s "http://127.0.0.1:8097/api/subscribe.php?unsubscribe=$TOK")
grep -q -- 'You are unsubscribed' <<<"$UNSUB" || { echo "FAIL unsubscribe page"; exit 1; }
grep -q -- 'background:#f3efe6' <<<"$UNSUB" || { echo "FAIL unsubscribe branding"; exit 1; }
[ "$(mariadb -N -h 127.0.0.1 -P 3307 -u root cms_test -e "SELECT COUNT(*) FROM subscribers WHERE email='reader@example.test'")" = "0" ] || { echo "FAIL unsubscribe did not delete"; exit 1; }
REUSE=$(curl -s "http://127.0.0.1:8097/api/subscribe.php?unsubscribe=$TOK")
grep -q -- 'Link not recognised' <<<"$REUSE" || { echo "FAIL reused token handled"; exit 1; }

# ---- Growth platform: API auth, CRUD, media, settings, beacon, analytics, IndexNow ----
BASE=http://127.0.0.1:8097
fail() { echo "FAIL $1"; exit 1; }
contains() { local url=$1 needle=$2 body; shift 2; body=$(curl -s "$@" "$url"); grep -q -- "$needle" <<<"$body"; }
dbsql() { mariadb -N -h 127.0.0.1 -P 3307 -u root cms_test -e "$1"; }

LOGIN=$(curl -s -X POST -H 'Content-Type: application/json' \
  --data '{"email":"harness@example.test","password":"harness-password"}' "$BASE/api/auth.php?action=login")
API_TOKEN=$(printf '%s' "$LOGIN" | php -r '$d=json_decode(stream_get_contents(STDIN),true); echo $d["token"] ?? "";')
API_CSRF=$(printf '%s' "$LOGIN" | php -r '$d=json_decode(stream_get_contents(STDIN),true); echo $d["csrf"] ?? "";')
[ ${#API_TOKEN} -eq 64 ] && [ ${#API_CSRF} -eq 64 ] || fail "api login returned no token/csrf: $LOGIN"
AUTH_H=(-H "X-Auth-Token: $API_TOKEN")
WRITE_H=(-H "X-Auth-Token: $API_TOKEN" -H "X-CSRF-Token: $API_CSRF" -H 'Content-Type: application/json')

NOAUTH=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/api/crud.php?entity=apps")
[ "$NOAUTH" = "401" ] || fail "crud without a token returned $NOAUTH"

APP_PAYLOAD='{"slug":"harness-api-app","name":"Harness API App","tagline":"Created by the smoke test","platforms":["iOS"],"links":{},"metrics":[],"features":[],"screenshots":[],"stack":[],"published":0,"sort_order":99}'
CREATE=$(curl -s -w '\n%{http_code}' -X POST "${WRITE_H[@]}" --data "$APP_PAYLOAD" "$BASE/api/crud.php?entity=apps")
CREATE_CODE=$(printf '%s' "$CREATE" | tail -1)
APP_ID=$(printf '%s' "$CREATE" | sed '$d' | php -r '$d=json_decode(stream_get_contents(STDIN),true); echo $d["id"] ?? "";')
[ "$CREATE_CODE" = "201" ] && [ -n "$APP_ID" ] || fail "app create: $CREATE_CODE $CREATE"
contains "$BASE/api/crud.php?entity=apps&id=$APP_ID" 'Harness API App' "${AUTH_H[@]}" || fail "created app not readable"
contains "$BASE/api/index.php?entity=apps" '"slug":"harness-api-app"' && fail "unpublished app is public"
PUB_CODE=$(curl -s -o /dev/null -w '%{http_code}' -X PUT "${WRITE_H[@]}" \
  --data '{"published":1,"seo_title":"Harness App SEO","aso_category":"Utilities"}' "$BASE/api/crud.php?entity=apps&id=$APP_ID")
[ "$PUB_CODE" = "200" ] || fail "publish returned $PUB_CODE"
contains "$BASE/api/index.php?entity=apps" '"slug":"harness-api-app"' || fail "published app missing from public API"
contains "$BASE/api/crud.php?entity=apps&id=$APP_ID" '"aso_category":"Utilities"' "${AUTH_H[@]}" || fail "ASO field not stored"
NOCSRF=$(curl -s -o /dev/null -w '%{http_code}' -X PUT "${AUTH_H[@]}" -H 'Content-Type: application/json' \
  --data '{"tagline":"x"}' "$BASE/api/crud.php?entity=apps&id=$APP_ID")
[ "$NOCSRF" = "403" ] || fail "write without CSRF returned $NOCSRF"
BADSLUG=$(curl -s -o /dev/null -w '%{http_code}' -X POST "${WRITE_H[@]}" \
  --data '{"slug":"Bad Slug","name":"x","tagline":"y"}' "$BASE/api/crud.php?entity=apps")
[ "$BADSLUG" = "422" ] || fail "invalid slug returned $BADSLUG"
DEL_CODE=$(curl -s -o /dev/null -w '%{http_code}' -X DELETE "${WRITE_H[@]}" "$BASE/api/crud.php?entity=apps&id=$APP_ID")
[ "$DEL_CODE" = "200" ] || fail "delete returned $DEL_CODE"
GONE=$(curl -s -o /dev/null -w '%{http_code}' "${AUTH_H[@]}" "$BASE/api/crud.php?entity=apps&id=$APP_ID")
[ "$GONE" = "404" ] || fail "deleted app still readable ($GONE)"
contains "$BASE/api/index.php?entity=apps" '"slug":"harness-api-app"' && fail "deleted app still public"

P_CREATE=$(curl -s -o /dev/null -w '%{http_code}' -X POST "${WRITE_H[@]}" --data '{"k":"api_test","v":"hello"}' "$BASE/api/crud.php?entity=profile")
[ "$P_CREATE" = "201" ] || fail "profile create returned $P_CREATE"
P_UPDATE=$(curl -s -o /dev/null -w '%{http_code}' -X PUT "${WRITE_H[@]}" --data '{"k":"api_test","v":"bye"}' "$BASE/api/crud.php?entity=profile")
[ "$P_UPDATE" = "200" ] || fail "profile update returned $P_UPDATE"
contains "$BASE/api/crud.php?entity=profile&k=api_test" '"v":"bye"' "${AUTH_H[@]}" || fail "profile value not updated"
contains "$BASE/api/index.php?entity=profile" '"k":"' || fail "public profile is not k/v rows"
P_DELETE=$(curl -s -o /dev/null -w '%{http_code}' -X DELETE "${WRITE_H[@]}" "$BASE/api/crud.php?entity=profile&k=api_test")
[ "$P_DELETE" = "200" ] || fail "profile delete returned $P_DELETE"
P_GONE=$(curl -s -o /dev/null -w '%{http_code}' "${AUTH_H[@]}" "$BASE/api/crud.php?entity=profile&k=api_test")
[ "$P_GONE" = "404" ] || fail "deleted profile key still readable ($P_GONE)"

printf 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==' | base64 -d > "$TMP/pixel.png"
UP=$(curl -s -w '\n%{http_code}' -X POST -H "X-Auth-Token: $API_TOKEN" -H "X-CSRF-Token: $API_CSRF" \
  -F folder=harness -F file=@"$TMP/pixel.png" "$BASE/api/upload.php")
UP_CODE=$(printf '%s' "$UP" | tail -1)
UP_BODY=$(printf '%s' "$UP" | sed '$d')
[ "$UP_CODE" = "201" ] || fail "upload returned $UP_CODE $UP_BODY"
UP_PATH=$(printf '%s' "$UP_BODY" | php -r '$d=json_decode(stream_get_contents(STDIN),true); echo $d["path"] ?? "";')
case "$UP_PATH" in /media/uploads/harness/*) ;; *) fail "unexpected upload path: $UP_PATH" ;; esac
[ -f "$PUB$UP_PATH" ] || fail "uploaded file missing from disk"
UP_NOCSRF=$(curl -s -o /dev/null -w '%{http_code}' -X POST -H "X-Auth-Token: $API_TOKEN" \
  -F folder=harness -F file=@"$TMP/pixel.png" "$BASE/api/upload.php")
[ "$UP_NOCSRF" = "403" ] || fail "upload without CSRF returned $UP_NOCSRF"

UA='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36'
BEACON='{"event":"page_view","path":"/harness","session":"0123456789abcdef0123456789abcdef","props":{"title":"Harness"},"utm":{"source":"harness","medium":"smoke"},"referrer":"example.test"}'
BEACON_CODE=$(curl -s -o /dev/null -w '%{http_code}' -A "$UA" -H 'Content-Type: application/json' \
  -H "Origin: $BASE" --data "$BEACON" "$BASE/api/track.php")
[ "$BEACON_CODE" = "204" ] || fail "beacon returned $BEACON_CODE"
[ "$(dbsql "SELECT COUNT(*) FROM analytics_events WHERE path='/harness' AND event='page_view'")" = "1" ] || fail "beacon not stored"
VISITOR=$(dbsql "SELECT visitor FROM analytics_events WHERE path='/harness' LIMIT 1")
printf '%s' "$VISITOR" | grep -Eq '^[a-f0-9]{32}$' || fail "visitor hash is not 32 hex: $VISITOR"
[ "$(dbsql "SELECT JSON_UNQUOTE(JSON_EXTRACT(utm,'\$.source')) FROM analytics_events WHERE path='/harness' LIMIT 1")" = "harness" ] || fail "utm not stored"
[ "$(dbsql "SELECT SUM(events) FROM analytics_daily WHERE path='/harness' AND event='page_view'")" -ge 1 ] || fail "daily rollup missing"
BOT_CODE=$(curl -s -o /dev/null -w '%{http_code}' -A 'curl/8.7.1' -H 'Content-Type: application/json' \
  -H "Origin: $BASE" --data "$BEACON" "$BASE/api/track.php")
[ "$BOT_CODE" = "204" ] || fail "bot beacon returned $BOT_CODE"
[ "$(dbsql "SELECT COUNT(*) FROM analytics_events WHERE path='/harness' AND event='page_view'")" = "1" ] || fail "bot beacon was stored"
CROSS_CODE=$(curl -s -o /dev/null -w '%{http_code}' -A "$UA" -H 'Content-Type: application/json' \
  -H 'Origin: http://evil.example' --data "$BEACON" "$BASE/api/track.php")
[ "$CROSS_CODE" = "204" ] || fail "cross-origin beacon returned $CROSS_CODE"
[ "$(dbsql "SELECT COUNT(*) FROM analytics_events WHERE path='/harness' AND event='page_view'")" = "1" ] || fail "cross-origin beacon was stored"
ADMIN_CODE=$(curl -s -o /dev/null -w '%{http_code}' -A "$UA" -H 'Content-Type: application/json' -H "Cookie: admin_token=$TOKEN" \
  -H "Origin: $BASE" --data "$BEACON" "$BASE/api/track.php")
[ "$ADMIN_CODE" = "204" ] || fail "admin beacon returned $ADMIN_CODE"
[ "$(dbsql "SELECT COUNT(*) FROM analytics_events WHERE path='/harness' AND event='page_view'")" = "1" ] || fail "admin visit was counted"
LEAVE='{"event":"page_leave","path":"/harness","session":"0123456789abcdef0123456789abcdef","props":{"dwell_ms":9999999}}'
curl -s -o /dev/null -A "$UA" -H 'Content-Type: application/json' -H "Origin: $BASE" --data "$LEAVE" "$BASE/api/track.php"
[ "$(dbsql "SELECT JSON_EXTRACT(props,'\$.dwell_ms') FROM analytics_events WHERE event='page_leave' LIMIT 1")" = "1800000" ] || fail "dwell_ms not clamped"

check admin/analytics.php 'Visitors'
check admin/analytics.php '/harness'

SET_HTML=$(curl -s -H "Cookie: admin_token=$TOKEN" "$BASE/admin/settings.php")
SET_CSRF=$(printf '%s' "$SET_HTML" | sed -n 's/.*name="csrf" value="\([^"]*\)".*/\1/p' | head -1)
[ -n "$SET_CSRF" ] || fail "settings csrf missing"
SET_SAVE=$(curl -s -H "Cookie: admin_token=$TOKEN" -X POST --data-urlencode "csrf=$SET_CSRF" \
  --data-urlencode 'ga4_id=G-HARNESS123' "$BASE/admin/settings.php")
grep -q -- 'Settings saved' <<<"$SET_SAVE" || fail "settings form did not save"
[ "$(dbsql "SELECT v FROM settings WHERE k='ga4_id'")" = "G-HARNESS123" ] || fail "settings value not written"
contains "$BASE/api/index.php?entity=settings" '"ga4_id":"G-HARNESS123"' || fail "public settings API missing ga4_id"
[ "$(dbsql "SELECT COUNT(*) FROM settings")" -ge 15 ] || fail "settings seed incomplete"

check admin/settings.php 'IndexNow'
IN_NOKEY=$(curl -s -o /dev/null -w '%{http_code}' -X POST "${WRITE_H[@]}" --data '{}' "$BASE/api/indexnow.php")
[ "$IN_NOKEY" = "422" ] || fail "indexnow without a key returned $IN_NOKEY"
dbsql "UPDATE settings SET v='a1b2c3d4e5f6a7b8a1b2c3d4e5f6a7b8' WHERE k='indexnow_key'"
printf '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url><loc>https://example.test/</loc></url></urlset>' > "$PUB/sitemap.xml"
IN_HOST=$(curl -s -o /dev/null -w '%{http_code}' -X POST "${WRITE_H[@]}" -H 'Host: localhost' --data '{}' "$BASE/api/indexnow.php")
[ "$IN_HOST" = "422" ] || fail "indexnow with a dotless host returned $IN_HOST (an outbound call may have been made)"
[ -f "$PUB/a1b2c3d4e5f6a7b8a1b2c3d4e5f6a7b8.txt" ] || fail "indexnow key file not written"
IN_GET=$(curl -s -o /dev/null -w '%{http_code}' "${AUTH_H[@]}" "$BASE/api/indexnow.php")
[ "$IN_GET" = "405" ] || fail "indexnow GET returned $IN_GET"

echo "PASS: CMS dashboard, editors, subscribers, API, enquiry intake, CSRF update, newsletter subscribe/unsubscribe"
echo "PASS: growth platform — API login, apps CRUD, profile KV, upload, settings, beacon filters, analytics dashboard, IndexNow guards"
