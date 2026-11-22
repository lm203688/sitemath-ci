# Pin every Pod target's deployment target inside the existing post_install hook.
# CocoaPods rejects a second post_install block, so we inject the loop instead.
path = "ios/Podfile"
src = File.read(path)
needle = "post_install do |installer|"
raise "post_install hook not found" unless src.include?(needle)

unless src.include?("IPHONEOS_DEPLOYMENT_TARGET\"] = \"16.0")
  injection = <<~RUBY
    post_install do |installer|
      installer.pods_project.targets.each do |t|
        t.build_configurations.each do |c|
          c.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "16.0"
        end
      end
  RUBY
  src = src.sub(needle, injection.chomp)
end

File.write(path, src)
puts "pinned 16.0 in #{path}"
