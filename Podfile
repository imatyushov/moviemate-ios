source 'https://cdn.cocoapods.org/'

platform :ios, '16.0'

target 'moviemate-ios' do
  use_frameworks!

  # Pods for MovieMate
  pod 'Alamofire'
  pod 'HandlersKit'
  pod 'SnapKit'
  pod 'YYText'

post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
	config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
      end
    end
  end
end