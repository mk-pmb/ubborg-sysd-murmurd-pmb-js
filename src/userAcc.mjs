// -*- coding: utf-8, tab-width: 2 -*-

import addOsUsersToGroup from 'ubborg-add-osusers-to-groups';

import facts from './facts';

const {
  muSrv,
  muHome,
} = facts;


const EX = async function userAcc(bun, mustPop) {
  const userIdNum = mustPop('num', 'userIdNum', 0);
  if (!userIdNum) { return; }
  const mumGid = (mustPop('num', 'groupIdNum', 0) || userIdNum);
  await bun.needs('osUserGroup', { grName: muSrv, grIdNum: mumGid });
  await bun.needs('osUser', {
    loginName: muSrv,
    interactive: false,
    homeDirPath: muHome,
    shell: false,
    disablePasswordLogin: true,
    userIdNum,
    groups: [muSrv],
  });
  await (function addExtraUsers() {
    const names = mustPop('undef | fal | ary | str', 'grAddUsers');
    if (!(names || false).length) { return; }
    return addOsUsersToGroup(names, muSrv, bun);
  }());
};


export default EX;
