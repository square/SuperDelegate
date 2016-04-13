Pod::Spec.new do |s|
  s.name     = 'SuperDelegate'
  s.version  = '0.8.0'
  s.license  = 'Apache License, Version 2.0'
  s.summary  = 'SuperDelegate provides a clean application delegate interface and protects you from bugs in the application lifecycle.'
  s.homepage = 'https://github.com/square/SuperDelegate'
  s.authors  = 'Square'
  s.source   = { :git => 'https://github.com/square/SuperDelegate.git', :tag => s.version }
  s.source_files = 'Sources/*.swift'
  s.ios.deployment_target = '8.0'
end
