module BssApi
  class HostableDataCollector < DataCollector

    def collect
      check_host
      super
    end

    private

    def check_host
      return unless params.key?(:host)

      raise InvalidCollectionSizeError, 'No accounts found.' if objects.empty?
      raise InvalidCollectionSizeError, 'Too many accounts found.' if objects.size > 1
      raise HostNotFoundError, 'Invalid host name.' if host.blank?
      raise NotAllowedHostError, 'No access to this host.' if objects.first.host_ids.exclude?(host.id)

      log
    end

    def reserved_keys
      super + %i[host]
    end

    def host
      @host ||= BssApi.configuration.host_class.find_by(name: params[:host])
    end

    def log
      BssApi.configuration.log_class.create(user_id: objects.first.id, host_id: host.id, query: params)
    end

  end
end
