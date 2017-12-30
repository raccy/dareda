var binDir, dirList, dstDir, exec, execSync, fs, path, spawn, srcDir;

fs = require('fs');

path = require('path');

({spawn, exec, execSync} = require('child_process'));

binDir = path.join('node_module', '.bin');

srcDir = 'dst';

dstDir = 'app';

dirList = {
  html: 'html',
  css: 'css',
  js: 'js'
};

task('build:html', 'build html', async function(option) {
  var stderr, stdout;
  ({stdout, stderr} = (await exec(path.join(binDir, 'pug'), ['-o', path.join(dstDir, dirList.html), path.join(srcDir, dirList.html)])));
  if (stdout) {
    console.log(stdout);
  }
  if (stderr) {
    return console.warn(stderr);
  }
});
