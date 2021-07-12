# frozen_string_literal: true

require_relative 'bss_api/version'
require_relative 'bss_api/data_collector'
require_relative 'bss_api/decorators/base'
require_relative 'bss_api/controllers/base_controller'

module BssApi
  class BaseError < StandardError; end

  class NotAllowedAttributesError < BaseError; end

  class InvalidCollectionSizeError < BaseError; end

  class << self

    def configuration
      @configuration ||= OpenStruct.new
    end

    def configure
      yield(configuration)
    end

  end
end
