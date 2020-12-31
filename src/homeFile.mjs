// -*- coding: utf-8, tab-width: 2 -*-

import mapMerge from 'map-merge-defaults-pmb';

import facts from './facts';

const EX = async function homeFile(bun, specs) {
  await bun.needs('userFile', mapMerge(EX.defaults, 'path', [].concat(specs)));
};

EX.defaults = {
  owner: facts.muSrv,
  pathPre: facts.muHome + '/',
  inheritOwnerWithin: facts.muHome,
};

export default EX;
