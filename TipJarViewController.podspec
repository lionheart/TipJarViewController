# vim: ft=ruby

Pod::Spec.new do |s|
  s.name             = 'TipJarViewController'
  s.version          =  "1.0.2"
  s.summary          = 'Easy, drop-in tipping for iOS apps.'
  s.homepage         = 'https://github.com/lionheart/TipJarViewController'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Dan Loewenherz' => 'dan@lionheartsw.com' }
  s.source           = { :git => 'https://github.com/lionheart/TipJarViewController.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/lionheartsw'
  s.documentation_url = 'https://code.lionheart.software/TipJarViewController/'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.ios.deployment_target = '10.3'
  s.swift_version = '5'

  s.source_files = 'TipJarViewController/Classes/**/*'
  # s.resource_bundles = {
  #   'TipJarViewController' => ['TipJarViewController/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'StoreKit'
  s.dependency 'QuickTableView', '~> 3'
  s.dependency 'SuperLayout', '~> 2'
  s.dependency 'LionheartExtensions', '~> 5'
end
