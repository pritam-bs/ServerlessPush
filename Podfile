# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'ServerlessPush' do
  plugin 'cocoapods-binary'
  keep_source_code_for_prebuilt_frameworks!
  enable_bitcode_for_prebuilt_frameworks!
  use_frameworks!
  
  use_frameworks!

  plugin 'cocoapods-keys', {
  :project => "ServerlessPushApp",
  :target => "ServerlessPush",
  :keys => [
    'AppIDClientSecretDevelop',      # IBM App ID clientSecret for develop
  ]}

  # SwiftLint
  pod 'SwiftLint'

  # LicensePlist
  pod 'LicensePlist'

  # SwiftGen
  pod 'SwiftGen'

  pod 'RxSwift', '~> 5.0'
  pod 'RxCocoa', '~> 5.0'
  pod 'RxGesture', '~>3.0'
  pod 'Moya', '~> 14.0'
  pod 'Moya/RxSwift', '~> 14.0'
  pod 'IQKeyboardManagerSwift'
  pod 'Reusable'
  pod 'NVActivityIndicatorView'
  pod 'RxFlow', '~> 2.11.0'
  pod 'DefaultsKit'
  pod 'KeychainAccess'
  pod 'SwiftyBeaver'
  pod 'AppAuth'
  pod 'ReachabilitySwift', '~>5.0'

  post_install do |installer|
    Xcodeproj::Project.open(*Dir.glob('*.xcodeproj')).tap do |project|
      project.targets.each do |target|
        if target.name == "ServerlessPush"
          target.build_configurations.each do |config|
            if config.name == "Debug" || config.name == "Stub"
              config.build_settings["CODE_SIGN_ENTITLEMENTS"] = "ServerlessPush/Config/Capabilities/development.entitlements"
              config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.mlbd.serverlesspush.debug"
              config.build_settings["BUNDLE_DISPLAY_NAME"] = "ServerlessPush Debug"
              config.build_settings["OTHER_SWIFT_FLAGS"] = "$(inherited) -D ENV_DEBUG"
            else
              config.build_settings["CODE_SIGN_ENTITLEMENTS"] = ""
              config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.mlbd.serverlesspush"
              config.build_settings["BUNDLE_DISPLAY_NAME"] = "ServerlessPush"
              config.build_settings["OTHER_SWIFT_FLAGS"] = "$(inherited) -D ENV_RELEASE"
            end
          end
        end
      end
      project.save
    end
    installer.pods_project.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
      config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
    end
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
        config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ""
        config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
        config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
        config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
      end
    end
  end
end
