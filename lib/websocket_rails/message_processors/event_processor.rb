module WebsocketRails
  module MessageProcessors
    class EventProcessor

      def processes?(message)
        message.type == :websocket_rails
      end

      include WebsocketRails::Processor

      def process_message(event)
        return if event.is_invalid?

        case
        when event.is_channel?
          WebsocketRails[event.channel].trigger_event event
        when event.is_user?
          connection = WebsocketRails.users[event.user_id.to_s]
          return if connection.nil?
          connection.trigger event
        else
          reload_event_map! unless event.is_internal?
          route event
        end
      end

      private

      def route(event)
        actions = []
        event_map.routes_for event do |controller_class, method|
          actions << Fiber.new do
            begin
              log_event(event) do
                controller = controller_factory.new_for_event(event, controller_class, method)

                controller.process_action(method, event)
              end
            rescue Exception => ex
              event.success = false
              event.data = extract_exception_data ex
              event.trigger
            end
          end
        end
        execute actions
      end

      def execute(actions)
        actions.map do |action|
          EM.next_tick { action.resume }
        end
      end

      def extract_exception_data(ex)
        if record_invalid_defined? and ex.is_a? ActiveRecord::RecordInvalid
          {
            :record => ex.record.attributes,
            :errors => ex.record.errors,
            :full_messages => ex.record.errors.full_messages
          }
        else
          ex if ex.respond_to?(:to_json)
        end
      end

      def record_invalid_defined?
        Object.const_defined?('ActiveRecord') and ActiveRecord.const_defined?('RecordInvalid')
      end
    end
  end
end
