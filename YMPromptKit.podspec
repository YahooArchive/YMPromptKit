Pod::Spec.new do |s|

  s.name            = "YMPromptKit"
  s.version         = "1.0.1"
  s.summary         = "An iOS soft prompting tookit by Yahoo!"

  s.description     = <<-DESC
                      YMPromptKit attempts to simplify your iOS app code by providing flexible and extensible tools for soft prompting.
                      DESC

  s.homepage        = "http://yahoo-mep.tumblr.com"
  s.screenshots     = "https://cloud.githubusercontent.com/assets/727953/6237605/548d7012-b6c2-11e4-97da-976398a5a7fa.png"
  s.license         = "Apache License, Version 2.0"
  s.author          = { "adamkaplan" => "adamkaplan@yahoo-inc.com" }
  s.source          = { :git => "https://github.com/yahoo/YMPromptKit.git", :tag => s.version.to_s }

  s.requires_arc    = true
  s.platform        = :ios, "7.0"
  s.weak_frameworks = "AVFoundation", "AssetsLibrary", "EventKit", "AddressBook", "CoreLocation"

  s.subspec 'SystemPrompts' do |ss|
    ss.source_files = "YMPromptKit/systemprompts/*.{h,m}"
  end

  s.subspec 'Core' do |ss|
    ss.dependency 'YMPromptKit/SystemPrompts'
    ss.source_files = "YMPromptKit/*.{h,m}"
  end

  s.subspec 'SDCAlerts' do |ss|
    ss.dependency 'YMPromptKit/Core'
    ss.dependency "SDCAlertView", "~> 2.1.1"
    ss.source_files = "YMPromptKit/sdc/*.{h,m}"
    ss.xcconfig = { 'OTHER_CFLAGS' => '-DYMPROMPTKIT_SDCALERT_ENABLE=1' }
  end

  s.subspec 'NativeAlerts' do |ss|
    ss.dependency 'YMPromptKit/Core'
    ss.source_files    = "YMPromptKit/native/*.{h,m}"
    ss.xcconfig = { 'OTHER_CFLAGS' => '-DYMPROMPTKIT_NATIVEALERT_ENABLE=1' }
  end

  s.default_subspecs = 'SDCAlerts'
end
