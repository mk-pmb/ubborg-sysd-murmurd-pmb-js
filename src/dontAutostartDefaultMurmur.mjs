// -*- coding: utf-8, tab-width: 2 -*-

import facts from './facts';

const {
  muSvc,
} = facts;


const EX = async function dontAutostartDefaultMurmur(bun) {
  await bun.needs('admFile', [
    /* unreliable.
    // import sysdWants from 'ubborg-sysd-wants';
    sysdWants.preset({
      path: '90-dont-autostart-default-murmur', // higher number = weaker
      content: 'disable ' + muSvc,
    }),
    */
    { path: '90-dont-autostart-default-murmur.conf',
      pathPre: '/lib/systemd/system/' + muSvc + '.d/',
      mimeType: 'static_ini',
      content: { Unit: { ConditionFirstBoot: true } },
      // [2020-12-30} Apparently, having any config for ${muSvc} prevents
      // systemd-sysv-generator from adding a service unit based on
      // /etc/init.d/mumble-server.
    },
  ]);
};

export default EX;
