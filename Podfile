# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'
use_frameworks!

target 'InkSpace' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for InkSpace
  pod 'AFNetworking'
  pod 'SDWebImage'
  pod 'MJRefresh'
  pod 'JKCategories'
  pod 'KVOController'
  pod 'MJExtension'
  pod 'Masonry'
  pod 'JXCategoryView'
  pod 'JXPagingView/Pager'
  pod 'FLEX', :configurations => ['Debug']
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 15.0
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
        end
      end
    end
  end

end
