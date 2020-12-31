// -*- coding: utf-8, tab-width: 2 -*-

import objPop from 'objpop';
import mustBe from 'typechecks-pmb/must-be';
import absdir from 'absdir';
import sysdWants from 'ubborg-sysd-wants';
import dictToEnvPairs from 'dict-to-env-pairs-pmb';

import facts from './facts';
import homeFile from './homeFile';


const {
  muHome,
  muWrap,
  muSrv,
} = facts;

const relPath = absdir(import.meta, '.');
const defaultTriggerUnit = 'multi-user.target';


const EX = async function customServer(bun, opt) {
  const mustPop = objPop(opt, { mustBe }).mustBe;
  const svcName = mustPop('nonEmpty str', 'svcName');
  const configDir = `${muHome}/${svcName}.conf.d`;
  const envPfx = 'murmur_';

  await homeFile(bun, {
    path: muWrap,
    enforcedModes: 'a=rx',
    mimeType: 'text/plain',
    uploadFromLocalPath: relPath('sysdwrap.sh'),
  });

  const svcUnit = {
    path: svcName,
    pathPre: '/lib/systemd/system/',
    pathSuf: '.service',
    mimeType: 'static_ini; speq',
    content: {
      Unit: {
        ConditionPathIsDirectory: configDir,
      },
      Service: {
        User: muSrv,
        Group: muSrv,
        WorkingDirectory: muHome,
        ExecStart: ['', `${muHome}/${muWrap} envcfg:${envPfx}`],
        Environment: dictToEnvPairs({
          cfgdir: configDir,
        }, { pfx: '"' + envPfx, suf: '"' }),
      },
    },
  };

  bun.needs('admFile', [
    svcUnit,
    sysdWants(mustPop('nonEmpty str', 'triggerUnit',
      defaultTriggerUnit), true, svcUnit),
  ]);

  mustPop.expectEmpty('Unsupported option(s)');
};


export default EX;