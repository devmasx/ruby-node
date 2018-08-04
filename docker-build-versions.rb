require 'erb'
require 'json'
require 'net/http'

DOCKERHUB_REPOSITORY = 'devmasx/ruby-node'.freeze

def fetch_all_ruby_versions
  response = JSON.parse Net::HTTP.get URI 'https://registry.hub.docker.com/v1/repositories/ruby/tags'
  response.map{|_| _["name"]}
end

# you need login in docker hub
def docker_push(tag)
  system("docker push #{DOCKERHUB_REPOSITORY}:#{tag}")
end

def docker_build(tag)
  system("docker build -t #{DOCKERHUB_REPOSITORY}:#{tag} .")
end

def dockerfile_build(base_image)
  template = ERB.new(File.read('Dockerfile.erb'))
  result = template.result(binding)
  File.open('Dockerfile', 'w') { |file| file.write(result) }
  puts "build Dockerfile #{base_image}"
end

base_images = fetch_all_ruby_versions.select { |_| _ =~ /(slim|stretch|jessie|wheezy)/ }

base_images.each do |base_image|
  tag_name = base_image.split(':').last
  dockerfile_build(base_image)
  docker_build(tag_name)
  docker_push(tag_name)
end
