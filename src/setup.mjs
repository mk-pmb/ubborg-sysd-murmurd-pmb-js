// -*- coding: utf-8, tab-width: 2 -*-

import objPop from 'objpop';
import mustBe from 'typechecks-pmb/must-be';
import sysdWants from 'ubborg-sysd-wants';
import absdir from 'absdir';

const relPath = absdir(import.meta, '.');
const muSrv = 'mumble-server';
const muSvc = muSrv + '.service';
const muWrap = 'murmur-systemd-wrapper-pmb';

function transTrue(x, t) { return (x === true ? t : x); }


const EX = async function setupMurmurd(bun, opt) {
  const mustPop = objPop(opt, { mustBe }).mustBe;
  await EX.userAcc(bun, mustPop);
  await bun.needs('admFile', [
    sysdWants.preset({
      path: '99-dont-autostart-default-murmur', // 99 = least priority
      content: 'disable ' + muSvc,
    }),
    { path: '/usr/bin/' + muWrap,
      enforcedModes: 'a=rx',
      mimeType: 'text/plain',
      uploadFromLocalPath: relPath('sdwrap.sh'),
    },
  ]);

  const debPkgNames = transTrue(mustPop('bool | nonEmpty str | nonEmpty ary',
    'debPkg', true), 'mumble-server');
  await (debPkgNames && bun.needs('debPkg', debPkgNames));

  mustPop.expectEmpty('Unsupported option(s)');
};


Object.assign(EX, {

  async userAcc(bun, mustPop) {
    const userIdNum = mustPop('num', 'userIdNum', 0);
    if (!userIdNum) { return; }
    const mumGid = (mustPop('num', 'groupIdNum', 0) || userIdNum);
    await bun.needs('osUser', {
      loginName: muSrv,
      interactive: false,
      homeDirPath: '/var/lib/' + muSrv,
      shell: false,
      userIdNum,
      gid: mumGid,
      groups: [muSrv],
    });
  },

});


export default EX;
