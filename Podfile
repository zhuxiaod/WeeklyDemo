# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'WeeklyReportDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks! :linkage => :static  # 修改这行

  # Pods for WeeklyReportDemo
  pod 'Masonry'
  
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "13.0"
      end
    end
  end