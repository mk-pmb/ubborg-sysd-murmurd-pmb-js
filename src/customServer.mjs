// -*- coding: utf-8, tab-width: 2 -*-

import objPop from 'objpop';
import mustBe from 'typechecks-pmb/must-be';
import absdir from 'absdir';
import sysdWants from 'ubborg-sysd-wants';

import facts from './facts';
import homeFile from './homeFile';
import svcUnitTemplate from './svcUnitTemplate';

const {
  muWrap,
} = facts;


const relPath = absdir(import.meta, '.');
const defaultTriggerUnit = 'multi-user.target';


const EX = async function customServer(bun, opt) {
  const mustPop = objPop(opt, { mustBe }).mustBe;
  const svcName = mustPop('nonEmpty str', 'svcName');

  await homeFile(bun, {
    path: muWrap,
    enforcedModes: 'a=rx',
    mimeType: 'text/plain',
    uploadFromLocalPath: relPath('sysdwrap.sh'),
  });

  await EX.putIni(bun, svcName,
    mustPop('undef | fal | ary | dictObj', 'putIni'));

  const svcUnitSpec = svcUnitTemplate(svcName);
  bun.needs('admFile', [
    svcUnitSpec,
    sysdWants(mustPop('nonEmpty str', 'triggerUnit',
      defaultTriggerUnit), true, svcUnitSpec),
  ]);

  mustPop.expectEmpty('Unsupported option(s)');
};


async function putIni(bun, svcName, spec) {
  if (!spec) { return; }
  if (Array.isArray(spec)) { return putIni(bun, svcName, { local: spec }); }
  const mimeType = 'utf8_tw; 20; %3B';
  const inis = Object.entries(spec).map(function genOneIni([k, v]) {
    return { path: `${svcName}/cfg/${k}.ini`, mimeType, content: v };
  });
  await homeFile(bun, [`${svcName}/`, ...inis]);
}







Object.assign(EX, {

  putIni,

});

export default EX;
