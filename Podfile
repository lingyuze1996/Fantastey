# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'Fantastey' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Fantastey
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'GoogleSignIn'

end

post_install do |pi|
	pi.pods_project.targets.each do |t|
		t.build_configurations.each do |config|
			config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
		end
	end
end
