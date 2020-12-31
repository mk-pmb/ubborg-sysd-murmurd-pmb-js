// -*- coding: utf-8, tab-width: 2 -*-

import mustBe from 'typechecks-pmb/must-be';
import mapMerge from 'map-merge-defaults-pmb';

import facts from './facts';

const {
  muHome,
  muSrv,
} = facts;


const EX = async function homeSymDir(bun, dest) {
  mustBe('undef | nonEmpty str', 'homeSymDest')(dest);
  if (!dest) { return; }
  await bun.needs('userFile', mapMerge({ owner: muSrv }, 'path', [
    `${muHome} =-> ${dest}/`,
    `${dest}/`,   // <-- Set owner of link target
  ]));
};


export default EX;
