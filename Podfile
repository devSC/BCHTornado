platform :ios, "9.0"
inhibit_all_warnings! # this will disable all the warnings for all pods
use_frameworks!

target 'BCHTornado' do
# Comment the next line if you're not using Swift and don't want to use dynamic frameworks

pod 'SnapKit', '4.0.0'
pod 'pop',                  '1.0.9'
pod 'Reveal-SDK', '4',       :configurations => ["Debug"]
pod 'Result', '~> 3.0.0'
pod 'RxSwift',    '~> 4.0'
pod 'RxCocoa',    '~> 4.0'
pod 'Action'
pod 'Moya/RxSwift', '~> 11.0'
pod 'TextFieldEffects'
pod 'IQKeyboardManagerSwift'


#- Integrate SwiftStdlib extensions only:
pod 'SwifterSwift/SwiftStdlib'
#- Integrate Foundation extensions only:
pod 'SwifterSwift/Foundation'
#- Integrate AppKit extensions only:
pod 'PKHUD', '~> 5.0'

# For keystone
pod 'BigInt'
pod 'CryptoSwift'
pod 'TrezorCrypto'
pod 'KeychainSwift'

target 'BCHTornadoTests' do
inherit! :search_paths
# Pods for testing
end

target 'BCHTornadoUITests' do
inherit! :search_paths
# Pods for testing
end
end

post_install do |installer|
installer.pods_project.build_configurations.each do |config|
config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ""
config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"

end
installer.pods_project.targets.each do |target|
target.build_configurations.each do |config|
config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ""
config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
end
end
end





