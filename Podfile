# Uncomment the next line to define a global platform for your project
platform :ios, '17.0'

target 'TrackerApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      end
    end
  end

  # Pods for TrackerApp
  pod 'SwiftSoup'

  target 'TrackerAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'TrackerAppUITests' do
    # Pods for testing
  end

end

target 'TrackerWidgetExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TrackerWidgetExtension
  pod 'SwiftSoup'
end
