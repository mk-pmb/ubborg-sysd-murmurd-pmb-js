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
    [database]='./murmurd.sqlite'
    [logfile]='./logs/%y%m%d.%H%M%S.log'
    [pidfile]='./murmurd.pid'

    # Persistence
    [sqlite_wal]=2

    # Branding
    [registerName]='Mumble Server'
    [welcometext]='<br />Welcome to this Murmur server.<br />'

    # Client security
    [allowhtml]=false

    # Access tokens etc.
    [sysdwrap_supw]=
    [icesecretread]=
    [icesecretwrite]=
    [serverpassword]=
    [certrequired]=true

    # Logging settings
    [sysdwrap_extra_flags]= # e.g. '-v'
    [obfuscate]=true

    # Network tweaks
    [bandwidth]=64k
    # ^-- Rather conservative. For HQ audio streaming inside a fast LAN,
    #     you could probably afford 192k even.
    #     NB: The maximum quality in the GUI slider in the default client
    #     currently (2021-01-02) goes up to 96k.
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
  local INI='murmurd.ini.gen'
  sdw_path_tmpl database
  sdw_path_tmpl logfile
  sdw_path_tmpl pidfile
  >>"$INI" || return $?
  chmod a=,u+rw -- "$INI" || return $?
  sdw_render_ini >"$INI" || return $?
  local MMD_OPT=(
    -ini "$INI"
    -fg
    ${INI_OPT[sysdwrap_extra_flags]}
    )
  sdw_configure_supw || return $?
  exec murmurd "${MMD_OPT[@]}" || return $?
}


function sdw_configure_supw () {
  local VER="$(murmurd --version 2>&1)"
  case "$VER" in
    '<F>'*' murmurd -- 1.3.3-1~ppa1~focal1' | \
    '<F>UBAR' )
      echo "W: skip configuring superuser password: version $(
        )${VER#* -- } is too broken." >&2
      return 0;;
  esac

  local SUPW="${INI_OPT[sysdwrap_supw]}"
  case "$SUPW" in
    '' ) murmurd "${MMD_OPT[@]}" -disablesu; return $?;;
    * ) murmurd "${MMD_OPT[@]}" -readsupw <<<"$SUPW"; return $?;;
  esac
}


function sdw_path_tmpl () {
  local KEY="$1"
  local VAL="${INI_OPT[$KEY]}"
  if [[ "$VAL" == *'%'* ]]; then
    VAL="${VAL//%%/%% }"
    VAL="${VAL//%i/$BASH_PID}"
    printf -v VAL "%($VAL)T"
    VAL="${VAL//%% /%%}"
  fi
  [ "${VAL:0:2}" == ./ ] || VAL="$PWD${VAL:1}"
  mkdir --parents -- "$(dirname -- "$VAL")"
  INI_OPT["$KEY"]="$VAL"
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
  readarray -t LINES < <(sed -re 's!^\s+!!; s!\s*=\s*!=!' -- "$INI")
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
        ICE_OPT+=( "$KEY=$VAL" )
        continue;;
      sysdwrap_* ) continue;;
      bandwidth )
        case "$VAL" in
          *k ) let VAL="${VAL%k} * 1000";;
          *K ) let VAL="${VAL%k} * 1024";;
        esac;;
    esac
    echo "$KEY=$VAL"
  done
  echo
  echo "[Ice]"
  printf '%s\n' "${ICE_OPT[@]}"
}









sysdwrap "$@"; exit $?
