Pod::Spec.new do |spec|
  spec.name         = "SensorTest"
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

  spec.source_files = "SensorTest/Sources"
  spec.frameworks = "Foundation", "XCTest"
  spec.dependency "RxSwift",  "~> 5.0.0"
  spec.dependency "RxCocoa", "~> 5.0.0"
  spec.dependency "RxTest", "~> 5.0.0"
end
