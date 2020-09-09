#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint simple_edge_detection.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'simple_edge_detection'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin enabling the user to detect edges of a given image. It returns the relative coordinates of the detection rectangle.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://www.flutterclutter.dev'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'flutterclutter.dev' => 'fluttercluttedev@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*.{swift,c,m,h,mm,cpp,plist}'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'

  # Instructions specific for edge detection and OpenCV
  s.preserve_paths = 'opencv2.framework'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework opencv2' }
  s.vendored_frameworks = 'opencv2.framework'
  s.frameworks = 'AVFoundation'
  s.library = 'c++'
end