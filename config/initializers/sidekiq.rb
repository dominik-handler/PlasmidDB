Sidekiq.configure_server do |config|
  config.redis = { :url => Settings.sidekiq_redis_url, :namespace => Settings.applicaton_name }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => Settings.sidekiq_redis_url, :namespace => Settings.applicaton_name }
end
