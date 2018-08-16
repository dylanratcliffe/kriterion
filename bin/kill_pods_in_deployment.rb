#! /bin/env ruby
require 'kubeclient'
require 'pry'

deployment     = ARGV[0]
auth_method    = ARGV[1]

namespace = 'kriterion'

case auth_method
when 'k8s'
  # Use the token file that exists within K8s
  auth_options = {
    bearer_token_file: '/var/run/secrets/kubernetes.io/serviceaccount/token'
  }

  ssl_options = {}
  if File.exist?('/var/run/secrets/kubernetes.io/serviceaccount/ca.crt')
    ssl_options[:ca_file] = '/var/run/secrets/kubernetes.io/serviceaccount/ca.crt'
  end

  client = Kubeclient::Client.new(
    'https://kubernetes.default.svc',
    'v1',
    auth_options: auth_options,
    ssl_options:  ssl_options
  )
when 'local'
  # require 'googleauth'
  config        = Kubeclient::Config.read(ENV['KUBECONFIG'] || '~/.kube/config')
  context       = config.context

  auth_options = {
    bearer_token: ENV['KUBETOKEN']
  }

  client = Kubeclient::Client.new(
    context.api_endpoint,
    context.api_version,
    ssl_options: context.ssl_options,
    auth_options: auth_options
  )
end

puts "Discovering Services..."
client.discover

puts "Getting Pods..."

client.get_pods(namespace: namespace).each do |pod|
  # Check if it's one that we want to kill
  if pod[:metadata][:labels][:deployment] == deployment
    puts "Found pod #{pod[:metadata][:name]} in deployment #{pod[:metadata][:labels][:deployment]}"
    puts "Killing #{pod[:metadata][:name]}..."
    client.delete_pod(pod[:metadata][:name], namespace)
    puts "Done."
  end
end

puts "Done."