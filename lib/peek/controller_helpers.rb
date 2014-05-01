module Peek
  module ControllerHelpers
    extend ActiveSupport::Concern

    included do
      prepend_before_filter :set_peek_request_id, :if => :peek_enabled?
      helper_method :peek_enabled?
    end

    protected

    def set_peek_request_id
      Peek.request_params = env['action_dispatch.request.path_parameters']
      Peek.request_id = env['action_dispatch.request_id']
    end

    def peek_enabled?
      Peek.enabled?
    end
  end
end
