

Pod::Spec.new do |spec|

  

  spec.name         = "OSS2"
  spec.version      = "0.0.1"
  spec.summary      = "测试的智网通SDK."

  
  spec.description  = <<-DESC
                 这是给智网通使用的一款SDK
                 DESC

  spec.homepage     = "https://github.com/zhangzhaochaol/OSS2.git"
 

  #spec.license      = "MIT (example)"
  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }



  spec.author             = { "zzc" => "zhangzc" }
 

  # spec.platform     = :ios
   spec.platform     = :ios, "10.0"


   spec.frameworks = 'UIKit', 'QuartzCore', 'Foundation'


 

    spec.source       = { :git => "https://github.com/zhangzhaochaol/OSS2.git", :tag => "#{spec.version}" }


  spec.source_files  = "OSS2", "OSS2/**/*.{h,m}"
  spec.exclude_files = "OSS2/Exclude"

  

   spec.requires_arc = true



end



