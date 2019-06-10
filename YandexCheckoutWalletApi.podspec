Pod::Spec.new do |s|
  s.name      = 'YandexCheckoutWalletApi'
  s.version   = '1.1.0'
  s.homepage  = 'https://github.com/yandex-money/yandex-checkout-wallet-api-swift'
  s.license   = {
    :type => "MIT",
    :file => "LICENSE"
  }
  s.authors = 'Yandex Checkout'
  s.summary = 'Yandex Checkout Wallet Api iOS'

  s.source = { 
    :git => 'https://github.com/yandex-money/yandex-checkout-wallet-api-swift.git',
    :tag => s.version.to_s 
  }

  s.ios.deployment_target = '8.0'
  s.swift_version = '4.2'

  s.ios.source_files  = 'YandexCheckoutWalletApi/**/*.{h,swift}', 'YandexCheckoutWalletApi/*.{h,swift}'

  s.ios.dependency 'FunctionalSwift', '~> 1.1.0'
  s.ios.dependency 'YandexMoneyCoreApi', '~> 1.6.0'
end
