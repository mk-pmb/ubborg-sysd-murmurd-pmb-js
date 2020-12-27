#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function sdwrap () {
  local INI_OPTS=()
  env | sort
  sleep 9009d
}


sdwrap "$@"; exit $?
