// -*- coding: utf-8, tab-width: 2 -*-

import dictToEnvPairs from 'dict-to-env-pairs-pmb';

import facts from './facts';

const {
  muHome,
  muWrap,
  muSrv,
} = facts;


function svcUnitTemplate(svcName) {
  const instanceDir = `${muHome}/%N`;
  return {
    mimeType: 'static_ini; speq', // ubborg's mimeFx magic at work
    pathPre: '/lib/systemd/system/',
    path: svcName,
    pathSuf: '.service',
    content: {
      Unit: {
        ConditionPathIsDirectory: instanceDir,
      },
      Service: {
        SyslogIdentifier: '%N',
        User: muSrv,
        Group: muSrv,
        WorkingDirectory: instanceDir,
        ExecStart: ['', `${muHome}/${muWrap} envcfg dircfg:cfg/ serve`],
        Environment: dictToEnvPairs({
          registerName: '%N@%H',
          welcometext: 'Welcome to %N@%H.',
        }, { pfx: '"murmur_', suf: '"' }),
      },
    },
  };
}

export default svcUnitTemplate;
