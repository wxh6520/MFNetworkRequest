Pod::Spec.new do |s|
  s.name         = "MFNetworkRequest"
  s.version      = "0.0.1"
  s.summary  = 'a network request tool using swift'
  s.homepage     = "https://github.com/wxh6520/MFNetworkRequest"
  s.license      = 'MIT'
  s.author       = {'wxh6520' => 'wxh6520'}
  # s.source       = { :git => 'https://github.com/wxh6520/MFNetworkRequest.git', :commit => 'a379f5178baf695e1a425ffb8c137c82f753cd7d' }
  s.source       = { :git => 'https://github.com/wxh6520/MFNetworkRequest.git', :tag => '0.0.1' }
  s.platform = :ios, '7.0'
  s.source_files = 'MFNetworkRequest_Swift/MFNetworkRequest.swift'
  # s.public_header_files  = 'MFNetworkRequest_Swift/MFNetworkRequest.swift'
  s.resource = "MFNetworkRequest_Swift/*.bundle"
  s.requires_arc = true
  # s.framework  = 'QuartzCore'
  s.dependency 'MBProgressHUD'
end


