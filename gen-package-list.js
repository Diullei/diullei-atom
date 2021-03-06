var fs = require('fs');
var path = require('path');

function removeA(arr) {
    var what, a = arguments, L = a.length, ax;
    while (L > 1 && arr.length) {
        what = a[--L];
        while ((ax= arr.indexOf(what)) !== -1) {
            arr.splice(ax, 1);
        }
    }
    return arr;
}

var app_path = process.argv[2];

var defaultPackages = '';
var packagesToRemove = '';
var customPackages = '';

if (fs.existsSync(path.join(app_path, 'package-list.txt'))) {
    defaultPackages = fs.readFileSync(path.join(app_path, 'package-list.txt')).toString();
}

if (fs.existsSync(path.join(app_path, 'package-black-list.txt'))) {
    packagesToRemove = fs.readFileSync(path.join(app_path, 'package-black-list.txt')).toString();
}

if (fs.existsSync(path.join(app_path, 'package-custom-list.txt'))) {
    customPackages = fs.readFileSync(path.join(app_path, 'package-custom-list.txt')).toString();
}

function packageInstalled(name) {
    var found = false;
    if (fs.existsSync(path.join(app_path, 'packages'))) {
        var dirlist = fs.readdirSync(path.join(app_path, 'packages'));
        for (var i = 0; i < dirlist.length; i++) {
            if (fs.existsSync(path.join(app_path, 'packages', dirlist[i]))) {
                if (dirlist[i].toUpperCase() == name.toUpperCase()) {
                    found = true;
                }
            }
        }
    }
    return found;
}

var listToInstall = [];

var tmp = defaultPackages.split(/(\r\n|\n)/mg);
tmp.forEach(function(package){
    if (package.trim() !== '' && !(package.trim().indexOf('#') === 0)) {
        if (!packageInstalled(package)) {
            listToInstall.push(package);
        }
    }
});

tmp = packagesToRemove.split(/(\r\n|\n)/mg);
tmp.forEach(function(package){
    if (package.trim() !== '' && !(package.trim().indexOf('#') === 0)) {
        removeA(listToInstall, package);
    }
});

tmp = customPackages.split(/(\r\n|\n)/mg);
tmp.forEach(function(package){
    if (package.trim() !== '' && !(package.trim().indexOf('#') === 0)) {
        if (!packageInstalled(package)) {
            listToInstall.push(package);
        }
    }
});

var listToInstallFile = '';

listToInstall.forEach(function(package){
    listToInstallFile += package + '\n';
});

fs.writeFileSync(path.join(app_path, 'tmp-packages-list.txt'), listToInstallFile);
