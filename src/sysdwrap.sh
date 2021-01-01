#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function sysdwrap () {
  local -A INI_OPT=(
    # To generate a default config with explanations, run as not root:
    # murmur-user-wrapper -i

    # Network basics
    [port]=64738
    [allowping]=true
    [users]=32

    # Paths
    [database]=
    [logfile]=
    [pidfile]=

    # Persistence
    [sqlite_wal]=2

    # Branding
    [registerName]='Mumble Server'
    [welcometext]='<br />Welcome to this Murmur server.<br />'

    # Client security
    [allowhtml]=false

    # Access tokens etc.
    [icesecretread]=
    [icesecretwrite]=
    [serverpassword]=
    [certrequired]=true

    # Log file privacy
    [obfuscate]=true

    # Network tweaks
    [bandwidth]=72000
    [timeout]=120
    [messageburst]=5
    [messagelimit]=1

    # Ice stuff
    [Ice__Warn__UnknownProperties]=1
    [Ice__MessageSizeMax]=65536
    )

  local OP= ARG= RV=
  local DBGLV="${DEBUGLEVEL:-0}"
  while [ "$#" -ge 1 ]; do
    OP="$1"; shift
    ARG="${OP#*:}"
    [ "$ARG" == "$OP" ] && ARG=
    OP="${OP%%:*}"
    dbgp "op='$OP', arg='$ARG'"
    sdw_"$OP" "$ARG"; RV=$?
    dbgp "op='$OP', arg='$ARG', rv=$RV"
    [ "$RV" == 0 ] || return "$RV"
  done
}


function dbgp () { [ "$DBGLV" -ge 2 ] && echo "D: $*" >&2; return 0; }


function sdw_serve () {
  mkdir --parents run
  local INI='run/murmurd.generated.ini'
  sdw_render_ini >"$INI" || return $?
  pwd
  exec sleep 9009d
}


function sdw_dircfg () {
  local PATH_PFX="$1"
  local INI=
  dbgp "$FUNCNAME" "$PATH_PFX"
  for INI in "$PATH_PFX"*.ini; do
    dbgp "$FUNCNAME" "$INI?"
    [ -f "$INI" ] || continue
    sdw_inicfg "$INI" || return $?
  done
}


function sdw_inicfg () {
  local INI="$1" KEY= VAL=
  local LINES=()
  dbgp "$FUNCNAME" "$INI"
  readarray -t LINES < <(sed -re 's~^\s+~~' -- "$INI")
  for VAL in "${LINES[@]}"; do
    case "$VAL" in
      '[Ice]' | \
      '' | '#'* | ';'* ) continue;;
      '['*']' ) echo "E: unsupported INI section: $VAL in $INI" >&2; return 3;;
    esac
    KEY="${VAL%%=*}"
    VAL="${VAL#*=}"
    KEY="${KEY//\./__}"
    dbgp "$FUNCNAME" "$INI" "$KEY=‹$VAL›"
    INI_OPT["$KEY"]="$VAL"
  done
}


function sdw_envcfg () {
  local ENV_PFX="${1:-murmur_}"
  local KEYS=()
  readarray -t KEYS < <(env | LANG=C grep -oPe '^\w+=')
  local KEY= VAL= CUT="${#ENV_PFX}"
  for KEY in "${KEYS[@]}"; do
    KEY="${KEY%=}"
    case "$KEY" in
      "$ENV_PFX"* ) ;;
      * ) continue;;
    esac
    VAL=
    eval 'VAL="$'"$KEY"'"'
    [ -z "$VAL" ] || INI_OPT["${KEY:$CUT}"]="$VAL"
  done
}


function sdw_render_ini () {
  local KEY= VAL=
  local ICE_OPT=()
  local SORTED=()
  readarray -t SORTED < <(printf '%s\n' "${!INI_OPT[@]}" | sort -V)
  for KEY in "${SORTED[@]}"; do
    VAL=
    VAL="${INI_OPT[$KEY]}"
    case "$VAL" in
      '"'*'"' ) ;;
      *[^A-Za-z0-9_-]* ) VAL='"'"$VAL"'"';;
    esac
    case "${KEY,,}" in
      ice__* )
        KEY="${KEY//__/.}"
        ICE_OPT+=( "$KEY=$VAL" );;
      * ) echo "$KEY=$VAL";;
    esac
  done
  echo
  echo "[Ice]"
  printf '%s\n' "${ICE_OPT[@]}"
}


sysdwrap "$@"; exit $?
