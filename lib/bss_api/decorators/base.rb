module BssApi
  module Decorators
    module Base
      # Place methods here that will be included in all decorators.

      class Decorator
        DATETIME_FORMATS = %i[date time datetime].freeze

        class << self

          def allowed_fields
            @allowed_fields ||= model_class.column_names - forbidden_fields.map(&:to_s)
          end

          def allowed_methods
            @allowed_methods ||= allowed_fields + permitted_methods
          end

          def date_fields
            @date_fields ||= columns_with_types.select { |_, v| DATETIME_FORMATS.include?(v) }
          end

          def allowed_sort_fields
            @allowed_sort_fields ||= allowed_fields + allowed_fields.map { |f| "-#{f}" }
          end

          def pattern_filter_columns
            %w[]
          end

          private

          def forbidden_fields
            %w[]
          end

          def model_methods
            %w[]
          end

          def model_class
            "::#{module_parent.to_s.demodulize}".constantize
          end

          def permitted_methods
            (module_parent.public_instance_methods + model_methods).map(&:to_s)
          end

          def columns_with_types
            @columns_with_types ||= Hash[allowed_fields.map { |f| [f, model_class.type_for_attribute(f).type] }]
          end

          # TODO: remove in Rails 6
          def module_parent
            @module_parent ||= to_s.split('::')[0...-1].join('::').constantize
          end

        end

      end
    end
  end
end
