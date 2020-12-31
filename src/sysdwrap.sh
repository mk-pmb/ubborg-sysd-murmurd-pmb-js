#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function sysdwrap () {
  local INI_OPTS=()
  env | sort
  exec sleep 9009d
}


sysdwrap "$@"; exit $?
