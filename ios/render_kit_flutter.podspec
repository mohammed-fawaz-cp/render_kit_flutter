Pod::Spec.new do |s|
  s.name             = 'render_kit_flutter'
  s.version          = '1.0.0'
  s.summary          = 'A cross-platform native compiler integration plugin.'
  s.description      = <<-DESC
A cross-platform native compiler integration plugin.
                       DESC
  s.homepage         = 'https://github.com/mohammed-fawaz-cp/render_kit_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Mohammed Fawaz' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
