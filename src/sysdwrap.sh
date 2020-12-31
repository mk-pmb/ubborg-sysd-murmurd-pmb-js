#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function sysdwrap () {
  local -A INI_OPTS=(
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

    [Ice__Warn__UnknownProperties]=1
    [Ice__MessageSizeMax]=65536
    )

  local ACTION="${1:-serve}"; shift
  sdw_"$ACTION" "$@"; return $?
}


function sdw_debug () {
  echo -n 'args:'; printf ' ‹%s›' "$0" "$@"; echo
  env | sort
}


function sdw_serve () {
  sdw_debug
  echo
  sdw_render_ini
  exec sleep 9009d
}


function sdw_render_ini () {
  local KEY= VAL=
  local ICE_OPT=()
  local SORTED=()
  readarray -t SORTED < <(printf '%s\n' "${!INI_OPTS[@]}" | sort -V)
  for KEY in "${SORTED[@]}"; do
    VAL="${INI_OPTS[$KEY]}"
    case "$VAL" in
      *[^A-Za-z0-9_-]* ) VAL='"'"$VAL"'"';;
    esac
    case "${KEY,,}" in
      ice__* ) ICE_OPT+=( "${KEY//__/.}=$VAL" );;
      * ) echo "$KEY=$VAL";;
    esac
  done
  echo
  echo "[Ice]"
  printf '%s\n' "${ICE_OPT[@]}"
}


sysdwrap "$@"; exit $?
