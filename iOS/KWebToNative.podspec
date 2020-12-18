

Pod::Spec.new do |spec|

  spec.name         = "KWebToNative"
  spec.version      = "0.0.1"
  spec.summary      = "KWebToNative is bridge wrapper between javascript and WKWebview"

  spec.homepage     = "https://www.grootan.com"

  spec.license      = "MIT"

  spec.author             = { "Lokesh Ravichandru" => "Lokesh.ravichandru@grootan.com" }
  spec.platform     = :ios
  spec.source       = { :path => '.' }
  spec.source_files  = "KWebToNative"
  spec.swift_version = "5.0"

end
