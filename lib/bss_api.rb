# frozen_string_literal: true

require_relative 'bss_api/version'
require_relative 'bss_api/data_collector'
require_relative 'bss_api/hostable_data_collector'
require_relative 'bss_api/decorators/base'
require 'app/controllers/base_controller'

module BssApi
  class NotAllowedAttributesError < StandardError; end

  class InvalidCollectionSizeError < StandardError; end

  class HostNotFoundError < StandardError; end

  class NotAllowedHostError < StandardError; end

  class << self

    def configuration
      @configuration ||= OpenStruct.new
    end

    def configure
      yield(configuration)
    end

  end
end
