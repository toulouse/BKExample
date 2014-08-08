Pod::Spec.new do |s|
  s.name             = "BKRecursiveDescription"
  s.version          = "0.0.1"
  s.summary          = "A very simple interface to enable detailed, recursive descriptions of objects and their properties with a minimum amount of work."
  s.homepage         = "https://github.com/Basket/BKRecursiveDescription"
  s.license          = 'MIT'
  s.author           = { "Andrew Toulouse" => "andrew@atoulou.se" }
  s.source           = { :git => "https://github.com/Basket/BKRecursiveDescription.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'BKRecursiveDescription/*.{h,m}'
  s.public_header_files = 'BKRecursiveDescription/BKRecursiveDescription.h',
                          'BKRecursiveDescription/BKDescribable.h',
                          'BKRecursiveDescription/NSObject+BKRecursiveDescription.h'
  s.frameworks = 'Foundation'
  s.xcconfig = {
    'GCC_C_LANGUAGE_STANDARD' => 'gnu11'
  }

end
