require 'erb'
base_images = %w[
  ruby:2.2-slim
  ruby:2.2.10-slim
  ruby:2.3-slim
  ruby:2.3.7-slim
  ruby:2.4-slim
  ruby:2.4.4-slim
  ruby:2.5-slim
  ruby:2.5.1-slim
]

DOCKERHUB_REPOSITORY = 'devmasx/ruby-node'.freeze
# you need login in docker hub
def docker_push(tag)
  puts `docker push #{DOCKERHUB_REPOSITORY}:#{tag}`
end

def docker_build(tag)
  puts `docker build -t #{DOCKERHUB_REPOSITORY}:#{tag} .`
end

def build_dockerfile(base_image)
  template = ERB.new(File.read('Dockerfile.erb'))
  result = template.result(binding)
  File.open('Dockerfile', 'w') { |file| file.write(result) }
  puts "build Dockerfile #{base_image}"
end

base_images.each do |base_image|
  tag_name = base_image.split(':').last
  build_dockerfile(base_image)
  docker_build(tag_name)
end
# docker_push('ruby:2.2-slim')
