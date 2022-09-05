#
#  Be sure to run `pod spec lint LSRRouterKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|


  spec.name         = "LSRRouterKit"
  spec.version      = "1.3"
  spec.summary      = "路由跳转，页面间的解耦"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = <<-DESC
    路由跳转，页面间的解耦，用于模块化集成
                   DESC

  spec.homepage     = "https://github.com/lgy881228/LSRRouterKit"

  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  
  spec.author             = { "lgy881228" => "510687394@qq.com" }
 
 
  spec.source       = { :git => "https://github.com/lgy881228/LSRRouterKit.git", :tag => spec.version }

    spec.platform     = :ios
    spec.platform     = :ios, "9.0"
    spec.ios.deployment_target = "9.0"
    
  spec.requires_arc = true
  spec.source_files  = 'LSRRouter/Classes/**/*'
  #spec.exclude_files = "Classes/Exclude"

   spec.public_header_files = "Classes/**/*.h"
   spec.prefix_header_contents = '#import "LSRRouterKit.h"'

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

    # spec.resource_bundles = {
   #  'LSRRouter' => ['LSRRouter/Assets/*']
   #}

  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
