# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module Goobi   # This is your workflow package name (using CamelCase)
      class GoobiNotify # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot

        def initialize
          super('dor', Dor::Config.goobi.workflow_name, 'goobi-notify', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "goobi-notify working on #{druid}"
          handler = proc do |exception, attempt_number, _total_delay|
            raise exception if attempt_number >= Dor::Config.goobi.max_tries
          end

          with_retries(max_tries: Dor::Config.goobi.max_tries, handler: handler, base_sleep_seconds: Dor::Config.goobi.base_sleep_seconds, max_sleep_seconds: Dor::Config.goobi.max_sleep_seconds) do |_attempt|
            url = "#{Dor::Config.dor.service_root}/objects/#{druid}/notify_goobi"
            response = RestClient.post url,{}
            response.code  
          end                         
        end
      end
    end
  end
end