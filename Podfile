platform :ios, '12.0'

target 'Tinylog' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  # Pods for Tinylog
	pod 'SVProgressHUD'
	pod "Ensembles", "~> 1.0"
  pod 'SwiftLint'
  pod 'SnapKit', '~> 5.0.0'
  pod 'ReachabilitySwift'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'Nantes'

  target 'TinylogTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'SnapshotTesting'
  end
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
         end
    end
  end
end