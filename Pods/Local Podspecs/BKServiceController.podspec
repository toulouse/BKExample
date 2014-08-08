Pod::Spec.new do |s|
  s.name             = "BKServiceController"
  s.version          = "0.0.1"
  s.summary          = "A concurrent dependency-resolving code launcher intended for use at application startup."
  s.description      = <<-DESC
                       Application startup often requires several things to be executed as a precondition to making the app interactable. This is often done sequentially in the app delegate on the main thread; while this is very predictable, modern iOS devices have more than one core and benefit greatly from intelligent use of queues.

                       This framework aims to make service declaration and dependency resolution straightforward, and to accelerate startup times by maximizing use of multi-core devices.
                       DESC
  s.homepage         = "https://github.com/Basket/BKServiceController"
  s.license          = 'MIT'
  s.author           = { "Andrew Toulouse" => "andrew@atoulou.se" }
  s.source           = { :git => "https://github.com/Basket/BKServiceController.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'BKServiceController/*.{h,m}'
  s.public_header_files = 'BKServiceController/BKService.h',
                          'BKServiceController/BKServiceController.h',
                          'BKServiceController/BKServiceRegistrar.h'
  s.frameworks = 'UIKit'
end
