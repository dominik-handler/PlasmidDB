require 'clockwork'
require 'sidekiq'

require_relative "../config/boot"
require_relative "../config/environment"

module Clockwork
  ## generate full backups of oligodb
  every(1.day, "midnight.job.backup", :at => '14:03') do
    t = Time.new Time.at(Time.new+100).to_s.sub(/\s.+\s/," 14:03:30 ")
    PerformBackupWorker.perform_at(t)
  end
end
