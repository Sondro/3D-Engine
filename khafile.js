let project = new Project('3D_Engine');
project.addAssets('Assets/**');
project.addShaders('Shaders/**');
if (platform === 'html5' || platform === 'krom' || platform === 'node' || platform === 'debug-html5') {
	project.addAssets('Libraries/haxebullet/js/ammo/ammo.js');
}
project.addSources('Sources');
project.addLibrary('haxebullet');
resolve(project);
