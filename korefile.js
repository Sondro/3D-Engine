let fs = require('fs');
let path = require('path');
let project = new Project('BulletTest', __dirname);
project.targetOptions = {"html5":{},"flash":{},"android":{},"ios":{}};
project.setDebugDir('build/windows');
Promise.all([Project.createProject('build/windows-build', __dirname), Project.createProject('w:/CODE/Haxe/__IDE/Kha/KodeStudio/resources/app/extensions/kha/Kha', __dirname), Project.createProject('w:/CODE/Haxe/__IDE/Kha/KodeStudio/resources/app/extensions/kha/Kha/Kore', __dirname)]).then((projects) => {
	for (let p of projects) project.addSubProject(p);
	let libs = [];
	if (fs.existsSync(path.join('Libraries/haxebullet', 'korefile.js'))) {
		libs.push(Project.createProject('Libraries/haxebullet', __dirname));
	}
	Promise.all(libs).then((libprojects) => {
		for (let p of libprojects) project.addSubProject(p);
		resolve(project);
	});
});
