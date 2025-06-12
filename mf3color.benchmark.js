var nthread = 1;
for (var i = 0; i < process.argv.length; i++) {
  if (process.argv[i] == '-t') {
    nthread = parseInt(process.argv[i + 1]);
    i++;
  }
}
const chromePath = '/usr/bin/chromium-browser';
const puppeteer = require('puppeteer-core');
const fs = require('fs');
(async () => {
  var browser = await puppeteer.launch({ executablePath: chromePath });
  var page = await browser.newPage();
  await page.goto('http://localhost:8000/solver2/solve.html?use_dist4=1&stl=60&snc=1&conc=' + nthread);
  const fileElement = await page.waitForSelector('#selectFiles');
  const directory = 'solver_qc/mkd/dat/';
  const fileNames = [
      'Dist1_09F.dat',
      'Dist2_09F.dat',
      'Dist3_10FQ.dat',
      'Dist4_11F.dat',
      'Dist5_11F.dat',
      'DistP2_15F.dat'
  ].map(fileName => directory + fileName);
  await fileElement.uploadFile(...fileNames);
  await page.evaluate(function() {
    return new Promise((resolve) => {
      var resolvId = setInterval(() => {
        if (dist_files_loaded) {
          clearInterval(resolvId);
          resolve();
        }
      }, 100);
    });
  });
  eval(fs.readFileSync('moves.js') + '');
  const readline = require('readline');
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false
  });  
  for await (const scramble of rl) {
    var solved = "RRRRRRRRRGGGYYYBBBWWWGGGYYYBBBWWWGGGYYYBBBWWWOOOOOOOOO";
    var state = do_moves(solved, scramble, 0);
    var [logtxt, timeInc] = await page.evaluate(function(state) {
      return new Promise((resolve) => {
        window.facelets = state;
        window.facelets_arr = state.split('');
        var show_solution_wrap = window.show_solution;
        var startTime = +new Date;
        window.show_solution = function(e, w, search_time) {
          show_solution_wrap(e, w, search_time);
          window.show_solution = show_solution_wrap;
          resolve([logtxt.join('').replace(/<br>/g, '\n'), +new Date - startTime]);
        };
        solve();
      });
    }, state);
    var nodes = 0, tt = 1e9, ttc = 0;
    logtxt.replace(/([0-9]+) node/g, function(match, p1) {
      nodes += parseInt(p1);
    }).replace(/([.0-9]+) Search/g, function(match, p1) {
      ttc += ~~(parseFloat(p1) * 1000);
    });
    console.log("Solved, nodes: " + nodes + " tt: " + timeInc + " ms ttc: " + ttc + " ms, scramble=" + scramble);  
  }
  await browser.close();
})();
