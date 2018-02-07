
Pod::Spec.new do |s|
  s.name         = "WPSandBoxPreviewTool"
  s.version      = "0.0.2"
  s.summary      = "WPSandBoxPreviewTool"
  s.homepage     = "https://github.com/wenyhooo/WPSandBoxTool.git"
  s.license      = 'MIT'
  s.authors      = { "wenyhooo" => "871531334@qq.com"}
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/wenyhooo/WPSandBoxTool.git" ,:tag => s.version}
  s.source_files = 'WPSandBoxPreviewTool/*.{h,m,mm}'
  s.resources    = "WPSandBoxPreviewTool/iconSource/*.png"
  s.requires_arc = true
  s.frameworks = 'UIKit','CoreFoundation'
  
end

