Pod::Spec.new do |spec|
  spec.name         = "SensorTest"
  spec.version      = "0.2.0"
  spec.summary      = "The SensorTest framework comes with batteries included so you can start testing your apps with ease."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = <<-DESC
  Nowadays, mobile applications become increasingly powerful and complex, rich of features that try to improve the user's experience. But power is nothing without control: the more powerful (and complex) the app is, the highest the chance it can end up in an inconsistent state.
  The good news is our Sensor Architecture: an elegant and a good way to organise your code when working with complex applications. With the ability to define all the possible states, of each feature of a mobile application, the chances to end up in an inconsistent state are most unlikely. Thanks to the concept of the State Machine and its deterministic behaviour, we can be sure that all the transitions from a state to another state are regulated by a finite set of events that can happen.
  The SensorTest framework comes with batteries included so you can start testing your apps with ease.
  DESC

  spec.homepage     = "https://github.com/freenowtech/Sensor"
  spec.license      = { :type => "Apache License", :file => "LICENSE" }
  spec.author    = "Intelligent Apps GmbH."

  spec.swift_version = '5.2'
  spec.ios.deployment_target = "10.3"
  spec.osx.deployment_target = "10.13"
  spec.source       = { :git => "https://github.com/freenowtech/Sensor.git", :tag => "#{spec.version}" }

  spec.source_files = "SensorTest/Sources/**/*.swift"
  spec.test_spec 'SensorTestUnitTests' do |test_spec|
    test_spec.source_files = 'SensorTest/UnitTests/**/*.{h,m,swift}'
    test_spec.dependency 'RxTest',  "~> 5"
    test_spec.dependency "SnapshotTesting", "~> 1.7.2"
  end
  spec.frameworks = "Foundation", "XCTest"
  spec.dependency "RxSwift",  "~> 5"
  spec.dependency "RxCocoa", "~> 5"
  spec.dependency "RxTest", "~> 5"
end
