module BssApi
  class DataCollector
    FILTER_SUFFIXES = {
      '_gt'     => '>',
      '_gte'    => '>=',
      '_lt'     => '<',
      '_lte'    => '<=',
      '_ne'     => '!=',
      '_is'     => 'IS',
      '_is_not' => 'IS NOT'
    }.freeze
    FORMATTED_VALUES = {
      'null' => nil,
      'true' => true,
      'false' => false
    }.freeze

    attr_reader :params, :default_scope

    def initialize(default_scope, params = {})
      @default_scope = default_scope
      @params = params
    end

    def collect
      objects.map do |obj|
        obj.extend(decorator_module)
        Hash[select_params.map { |k| [k, decorator.date_fields.include?(k) ? obj.public_send(k).to_i : obj.public_send(k)] }]
      end
    end

    def doc
      {
        'allowed for filter and sort' => decorator.allowed_fields.sort,
        'allowed for select' => decorator.allowed_methods.sort,
        'filtered by timestamp' => decorator.date_fields.sort
      }
    end

    private

    def objects
      @objects ||=
        begin
          data = default_scope.order(sort_params)
          filter_params.each do |filter|
            data = data.where(filter)
          end

          data
        end
    end

    def class_name
      @class_name ||= default_scope.model_name.name.constantize
    end

    def decorator
      @decorator ||= "BssApi::Decorators::#{model_class}::Decorator".constantize
    end

    def decorator_module
      "BssApi::Decorators::#{model_class}".constantize
    end

    # Transform hash with suffixes to array of arguments for ActiveRecord filtering
    # Example:
    # Input: { created_at_lte: 228, id_ne: 10, name: 'example' }
    # Output: [['created_at <= ?', 228], ['id != ?', 10], { 'name' => 'example' }]
    def filter_params
      @filter_params ||=
        begin
          attrs = params.except(*reserved_keys)
          permitted_attrs = attrs.select { |k, _| decorator.allowed_fields.include?(k.to_s.gsub(suffixes_regexp, '')) }
          if permitted_attrs != attrs
            raise NotAllowedAttributesError,
                  "Attributes #{attrs.keys - permitted_attrs.keys} not allowed for filtering."
          end

          permitted_attrs.map do |k, v|
            operation = key_to_operation(k)
            cleared_field = key_without_suffix(k)
            value = prepared_value(v, cleared_field)
            # Plain equality operation?
            if k.to_s == operation
              { operation => value }
            else
              [operation, value]
            end
          end
        end
    end

    # Transform string with sort params to hash for ActiveRecord sorting
    # Example:
    # Input: 'id,-name,created_at'
    # Output: { 'id' => 'ASC', 'name' => 'DESC', 'created_at' => 'ASC' }
    def sort_params
      @sort_params ||=
        begin
          attrs = params[:sort]&.split(',')&.uniq || []
          permitted_attrs = attrs & decorator.allowed_sort_fields
          if permitted_attrs != attrs
            raise NotAllowedAttributesError, "Attributes #{attrs - permitted_attrs} not allowed for sorting."
          end

          Hash[permitted_attrs.map { |attr| attr.start_with?('-') ? [attr[1..-1], 'DESC'] : [attr, 'ASC'] }]
        end
    end

    # Transform string with select params to array for selecting
    # Example:
    # Input: 'id,name,created_at'
    # Output: ['id', 'name', 'created_at']
    def select_params
      @select_params ||=
        begin
          attrs = params[:select]&.split(',')&.uniq || []
          permitted_attrs = attrs.any? ? (attrs & decorator.allowed_methods) : decorator.allowed_methods
          return permitted_attrs if permitted_attrs == attrs || permitted_attrs == decorator.allowed_methods

          raise NotAllowedAttributesError, "Attributes #{attrs - permitted_attrs} not allowed for selecting."
        end
    end

    def key_without_suffix(key)
      key.to_s.gsub(suffixes_regexp, '')
    end

    def key_to_operation(key)
      # Replace suffix with valid SQL operation
      operation = key.to_s.gsub(suffixes_regexp) { |suffix| " #{FILTER_SUFFIXES[suffix]} ?" }

      # Set operation for pattern matching
      operation = "#{key} ILIKE ?" if (operation == key) && pattern_match?(key)

      operation
    end

    def prepared_value(value, cleared_key)
      # Convert value to valid format
      v = FORMATTED_VALUES.key?(value) ? FORMATTED_VALUES[value] : value

      # Convert value to date if it is a date field
      v = Time.at(v.to_i) if decorator.date_fields.include?(cleared_key)

      # Set pattern for pattern matching
      v = "%#{v}%" if pattern_match?(cleared_key)

      v
    end

    def suffixes_regexp
      @suffixes_regexp ||= /(#{FILTER_SUFFIXES.map { |k, _| Regexp.escape(k) }.join('|')})$/
    end

    def pattern_match?(column)
      decorator.pattern_filter_columns.include?(column)
    end

    def reserved_keys
      %i[controller action format select sort page limit]
    end

  end
end
