Pod::Spec.new do |s|
  s.name      = 'YooKassaWalletApi'
  s.version   = '2.3.1'
  s.homepage  = 'https://github.com/yoomoney/yookassa-wallet-api-swift'
  s.license   = {
    :type => "MIT",
    :file => "LICENSE"
  }
  s.authors = 'YooKassa'
  s.summary = 'YooKassa Wallet Api iOS'

  s.source = {
    :git => 'https://github.com/yoomoney/yookassa-wallet-api-swift.git',
    :tag => s.version.to_s
  }

  s.ios.deployment_target = '8.0'
  s.swift_version = '5.0'

  s.ios.source_files  = 'YooKassaWalletApi/**/*.{h,swift}', 'YooKassaWalletApi/*.{h,swift}'

  s.ios.dependency 'FunctionalSwift'
  s.ios.dependency 'YooMoneyCoreApi'
end
