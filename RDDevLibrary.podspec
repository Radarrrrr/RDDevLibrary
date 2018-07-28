Pod::Spec.new do |s|

  s.name         = "RDDevLibrary"
  s.version      = "1.0.0"
  s.summary      = "tools for create and scan qr code"
  s.homepage     = "https://github.com/Radarrrrr/RDDevLibrary"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Radar" => "imryd@163.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/Radarrrrr/RDDevLibrary.git", :tag => "1.0.0" }
  s.source_files  = "RDDevLibrary/*"
  s.requires_arc = true

end