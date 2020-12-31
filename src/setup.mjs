// -*- coding: utf-8, tab-width: 2 -*-

import objPop from 'objpop';
import mustBe from 'typechecks-pmb/must-be';

import customServer from './customServer';
import dontAutostartDefaultMurmur from './dontAutostartDefaultMurmur';
import facts from './facts';
import homeSymDir from './homeSymDir';
import userAcc from './userAcc';


function transTrue(x, t) { return (x === true ? t : x); }


const EX = async function setupMurmurd(bun, opt) {
  const mustPop = objPop(opt, { mustBe }).mustBe;

  await userAcc(bun, mustPop);
  await dontAutostartDefaultMurmur(bun);

  const debPkgNames = transTrue(mustPop('bool | nonEmpty str | nonEmpty ary',
    'debPkg', true), 'mumble-server');
  await (debPkgNames && bun.needs('debPkg', debPkgNames));

  mustPop.expectEmpty('Unsupported option(s)');
};


Object.assign(EX, {
  ...facts,
  homeSymDir,
  customServer,
});


export default EX;
