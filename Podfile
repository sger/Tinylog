platform :ios, '11.0'

target 'Tinylog' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  # Pods for Tinylog
  pod 'TTTAttributedLabel'
	pod 'SVProgressHUD'
	pod 'SGBackgroundView'
	pod "Ensembles", "~> 1.0"
  pod 'SwiftLint'
  pod 'SnapKit', '~> 5.0.0'
  pod 'ReachabilitySwift'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'

  target 'TinylogTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'SnapshotTesting', '~> 1.5'
  end

end

post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
    end
  end
end