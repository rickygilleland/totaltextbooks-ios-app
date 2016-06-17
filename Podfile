# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'Total Textbooks' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Total Textbooks
  pod "SwiftSpinner"
  pod "Material"
  pod "ZendeskSDK"
  pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
  pod 'Alamofire', '~> 3.4'
  pod 'HanekeSwift'
  pod 'TextFieldEffects'
  pod 'JSSAlertView'
  pod 'Google/Analytics'
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end

end
