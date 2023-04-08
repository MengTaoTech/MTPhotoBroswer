#
# Be sure to run `pod lib lint MTPhotoBroswer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MTPhotoBroswer'
  s.version          = '0.2.1'
  s.summary          = '图片放大浏览器'
  s.swift_version = '5.0'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "支持图片放大查看"

  s.homepage         = 'https://github.com/MengTaoTech/MTPhotoBroswer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cycweeds' => 'cycweeds@gmail.com' }
  s.source           = { :git => 'https://github.com/MengTaoTech/MTPhotoBroswer.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/   <TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'MTPhotoBroswer/Classes/**/*'

   s.dependency 'Kingfisher'
   s.dependency 'SnapKit'
end
