Pod::Spec.new do |s|
  s.name             = "Xniffer"
  s.version          = "3.0.0"
  s.summary          = "A swift network profiler built on top URLSession."
  s.homepage         = "https://github.com/xmartlabs/Xniffer"
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { "Xmartlabs SRL" => "swift@xmartlabs.com" }
  s.source           = { git: "https://github.com/xmartlabs/Xniffer.git", tag: s.version.to_s }
  s.social_media_url = 'https://twitter.com/xmartlabs'
  s.ios.deployment_target = '9.0'
  s.requires_arc = true
  s.source_files = ['Sources/**/*.xib', 'Sources/**/*.{swift}']
  s.ios.frameworks = 'UIKit', 'Foundation'
end
