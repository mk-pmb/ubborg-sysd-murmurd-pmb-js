// -*- coding: utf-8, tab-width: 2 -*-

const muSrv = 'mumble-server';

const facts = {
  muSrv,
  muSvc: muSrv + '.service',
  muHome: '/var/lib/' + muSrv,
  muWrap: 'util/murmur-systemd-wrapper-pmb.sh',
};

export default facts;
