Pod::Spec.new do |s|
  s.name             = 'APOperations'
  s.version          = '1.1'
  s.summary          = 'An Objective-C implementation of the WWDC 2015 Advanced NSOperations sample code'
  s.description      = <<-DESC
APOperations is an Objective-C implementation of the WWDC 2015 Advanced NSOperations sample code: https://developer.apple.com/videos/play/wwdc2015-226/
Also incorporates changes made to the sample code in PSOperations: https://github.com/pluralsight/PSOperations
                       DESC

  s.homepage         = 'https://github.com/iMinichrispy/APOperations'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alex Perez' => 'alex@iminichrispy.com' }
  s.source           = { :git => 'https://github.com/iMinichrispy/APOperations.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/iMinichrispy'

  s.ios.deployment_target = '8.0'

  s.source_files = 'APOperations/**/*.{h,m,swift}'
end
