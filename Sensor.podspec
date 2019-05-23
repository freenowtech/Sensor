Pod::Spec.new do |spec|
  spec.name         = "Sensor"
  spec.version      = "0.1.0"
  spec.summary      = "WIP"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = <<-DESC
  WIP...
                   DESC

  spec.homepage     = "https://github.com/mytaxi/Sensor"
  spec.license      = { :type => "Apache License", :file => "LICENSE" }
  spec.author    = "Intelligent Apps GmbH."

  spec.swift_version = '5.0'
  spec.platform     = :ios, "10.0"
  #spec.source       = { :git => "https://github.com/mytaxi/Sensor.git", :tag => "#{spec.version}" }
  spec.source       = { :git => "https://github.com/mytaxi/Sensor.git", :branch => "master" }

  spec.default_subspec = "Core"

  spec.subspec 'Core' do |sp|
    sp.module_name = "SensorCore"
    sp.source_files = "Sensor/Sources"
    sp.frameworks = "Foundation"
    sp.dependency "RxSwift",  "~> 5.0.0"
    sp.dependency "RxCocoa", "~> 5.0.0"
    sp.dependency "RxFeedback", "~> 3.0.0"
  end

  spec.subspec 'SensorTest' do |sp|
    sp.module_name = "SensorTest"
    sp.source_files = "SensorTest/Sources"
    sp.frameworks = "Foundation", "XCTest"
    sp.dependency "Sensor/Core", "~> #{spec.version}"
    sp.dependency "RxTest", "~> 5.0.0"
  end
end
