#
# Be sure to run `pod lib lint MCAssertReflectiveEqual.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MCAssertReflectiveEqual'
  s.version          = '0.0.1'
  s.summary          = 'An equality assertion utility using reflection for swift tests'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Tests are good. Writing production code just for the purpose of testing is not good if you can avoid it.
MCAssertReflectiveEqual works just like XCTest's XCAssertEqual but doesn't require Equatable items - it uses reflection to evaluate if two structs, classes, enums, primitives etc are equal or not. Don't write that equals function in your production code if you don't need it. Don't assert multiple fields in your tests
 - let MCAssertReflectiveEqual do the job for you and make tests easier to read write.'


                       DESC

  s.homepage         = 'https://github.com/motocodeltd/MCAssertReflectiveEqual'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Stefanos Zachariadis, motocode ltd' => 'first name at last name dot net' }
  s.source           = { :git => 'https://github.com/motocodeltd/MCAssertReflectiveEqual.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'MCAssertReflectiveEqual/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MCAssertReflectiveEqual' => ['MCAssertReflectiveEqual/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'XCTest'
  # s.dependency 'AFNetworking', '~> 2.3'
end
