Gem::Specification.new do |s|
  s.name        = 'vhosttool'
  s.version     = '0.0.1'
  s.date        = '2012-12-02'
  s.executables << 'vhosttool'
  s.summary     = "Manage apache2 vhosts on Kenny"
  s.description = "Create, disable, enable delete vhosts and associated web users"
  s.authors     = ["Aaron Bonner"]
  s.email       = 'ajbonner@gmail.com'
  s.files       = ["lib/vhosttool.rb", "bin/vhosttool", "templates/vhost.template"]
end
