RSpec.shared_examples 'BSS: index params validation' do |api_key, methods:, forbidden_fields: []|
  forbidden_fields_string = forbidden_fields.join(',')
  before(:each) { request.headers['Authorization'] = api_key }

  methods.each do |method|
    context 'JSON' do
      it 'raises exception with invalid select params' do
        public_send(method, :index, params: { select: "#{forbidden_fields_string},destroy,id" }, format: :json)
        expect(json_response).to eq(
                                   'error' => "Attributes #{forbidden_fields + %w[destroy]} not allowed for selecting."
                                 )
      end

      it 'raises exception with invalid sort params' do
        public_send(method, :index, params: { sort: "#{forbidden_fields_string},destroy,id" }, format: :json)
        expect(json_response).to eq(
                                   'error' => "Attributes #{forbidden_fields + %w[destroy]} not allowed for sorting."
                                 )
      end

      it 'raises exception with invalid filter params' do
        params = Hash[forbidden_fields.map { |f| [f, rand(10)] }]
        public_send(method, :index, params: { **params, destroy: true, id: rand(10) }, format: :json)
        expect(json_response).to eq(
                                   'error' => "Attributes #{forbidden_fields + %w[destroy]} not allowed for filtering."
                                 )
      end
    end

    context 'CSV' do
      it 'raises exception with invalid select params' do
        public_send(method, :index, params: { select: "#{forbidden_fields_string},destroy,id"  }, format: :csv)
        expect(csv_response).to eq(
                                  [["Attributes #{forbidden_fields + %w[destroy]} not allowed for selecting."]]
                                )
      end

      it 'raises exception with invalid sort params' do
        public_send(method, :index, params: { sort: "#{forbidden_fields_string},destroy,id"  }, format: :csv)
        expect(csv_response).to eq(
                                  [["Attributes #{forbidden_fields + %w[destroy]} not allowed for sorting."]]
                                )
      end

      it 'raises exception with invalid filter params' do
        public_send(method, :index, params: { **params, destroy: true, id: rand(10) }, format: :csv)
        expect(csv_response).to eq(
                                  [["Attributes #{forbidden_fields + %w[destroy]} not allowed for filtering."]]
                                )
      end
    end
  end
end
