// -*- coding: utf-8, tab-width: 2 -*-

import facts from './facts';

const {
  muHome,
  muWrap,
  muSrv,
} = facts;


function svcUnitTemplate(svcName) {
  const instanceDir = `${muHome}/${svcName}`;
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
        SyslogIdentifier: svcName,
        User: muSrv,
        Group: muSrv,
        WorkingDirectory: instanceDir,
        ExecStart: ['', `${muHome}/${muWrap} envcfg dircfg:cfg/ serve`],
      },
    },
  };
}

export default svcUnitTemplate;
