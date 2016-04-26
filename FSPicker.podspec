Pod::Spec.new do |s|
  s.name         = 'FSPicker'
  s.version      = '0.1.0'
  s.summary      = "Filestack's picker controller implementation."

  s.description  = <<-DESC
              Upload images and files of any kind. Transform them into different styles and formats. Deliver them rapidly and responsively to the world.
  DESC

  s.homepage     = 'https://github.com/filepicker/FSPicker'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Filestack' => 'lukasz@filestack.com' }

  s.source       = {
    :git => 'https://github.com/filestack/FSPicker.git',
    :tag => "#{s.version}"
  }

  s.ios.deployment_target = '8.4'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true

  s.dependency 'Filestack'
end
