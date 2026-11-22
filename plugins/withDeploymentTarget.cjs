/** Pins every Pod target to iOS 16 so Xcode 27 (min 15.0) can archive old podspecs. */
const { withDangerousMod } = require('@expo/config-plugins');
const fs = require('fs');
const path = require('path');

module.exports = (config) =>
  withDangerousMod(config, [
    'ios',
    async (cfg) => {
      const podfile = path.join(cfg.modRequest.platformProjectRoot, 'Podfile');
      if (!fs.existsSync(podfile)) return cfg;
      let src = fs.readFileSync(podfile, 'utf8');
      if (!src.includes('IPHONEOS_DEPLOYMENT_TARGET = "16.0"')) {
        src = src.replace(
          /post_install do \|installer\|/,
          `post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |build_config|
      build_config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = "16.0"
    end
  end`
        );
        fs.writeFileSync(podfile, src);
      }
      return cfg;
    },
  ]);
