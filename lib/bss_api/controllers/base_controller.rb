module BssApi
  class BaseController < ActionController::API
    include ActionController::MimeResponds

    before_action :authenticate_api!
    before_action :prepare_api_params, only: %i[index]

    # format.json -- JSON and */*
    # format.csv  -- CSV
    # format.any  -- Empty format
    def index
      @collection = data_collector.new(default_scope, @api_params).collect
      respond_to do |format|
        format.json { render status: 200, json: { collection_name => @collection } }
        format.csv  { send_data generate_csv(@collection), filename: "#{collection_name}-#{Date.today}.csv" }
        format.any  { render status: 200, json: { collection_name => @collection } }
      end
    rescue NotAllowedAttributesError, InvalidCollectionSizeError, HostNotFoundError, NotAllowedHostError => e
      respond_to do |format|
        format.json { render status: 400, json: { error: e.message } }
        format.csv  { send_data csv_error(e), filename: "#{collection_name}-error.csv" }
        format.any  { render status: 400, json: { error: e.message } }
      end
    end

    def create
      record = model_class.new(permitted_params)
      if record.save
        respond_to do |format|
          format.json { render status: 200, json: record.attributes }
          format.csv  { send_data generate_csv(record.attributes), filename: "#{model_name}-#{record.id}.csv" }
          format.any  { render status: 200, json: record.attributes }
        end
      else
        respond_to do |format|
          format.json { render status: 400, json: record.errors }
          format.csv do
            send_data csv_error(record.errors.full_messages), filename: "#{model_name}-#{record.id}-error.csv"
          end
          format.any { render status: 400, json: record.errors }
        end
      end
    end

    def doc
      render status: 200, json: data_collector.new(default_scope).doc
    end

    private

    def authenticate_api!
      api_key =
        if BssApi.configuration.api_key_prefix.present?
          "#{BssApi.configuration.api_key_prefix} #{BssApi.configuration.api_key}"
        else
          BssApi.configuration.api_key
        end
      return if request.headers['Authorization'] == api_key

      respond_to do |format|
        format.json { render status: 403, json: { error: 'denied' } }
        format.csv  { send_data csv_error('Denied error'), filename: 'error.csv' }
        format.any  { render status: 403, json: { error: 'denied' } }
      end
    end

    def prepare_api_params
      @api_params = params.permit!.to_h
      if request.content_type == 'text/csv' && csv_body_ids.present?
        @api_params[:id] = csv_body_ids
      elsif @api_params[model_id].present?
        @api_params[:id] ||= @api_params.delete(model_id)
      end
    end

    def csv_body_ids
      @csv_body_ids ||= request.body.read&.split&.map(&:to_i)
    end

    def default_scope; end

    def permitted_params; end

    def data_collector
      DataCollector
    end

    def model_class
      default_scope.model_name.name.constantize
    end

    def model_name
      model_class.to_s.downcase
    end

    def model_id
      "#{model_name}_id"
    end

    def collection_name
      model_name.pluralize
    end

    def generate_csv(*collection)
      CSV.generate do |csv|
        collection.flatten(1).map do |item|
          csv << item.values
        end
      end
    end

    def csv_error(*messages)
      CSV.generate do |csv|
        messages.flatten(1).each do |message|
          csv << [message]
        end
      end
    end

  end
end
