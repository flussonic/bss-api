RSpec.shared_examples 'BSS: index params validation' do |api_key, methods:|
  before(:each) { request.headers['Authorization'] = api_key }

  methods.each do |method|
    context 'JSON' do
      it 'raises exception with invalid select params' do
        public_send(method, :index, params: { select: 'invalid_column,destroy,id' }, format: :json)
        expect(json_response).to eq('error' => "Attributes #{%w[invalid_column destroy]} not allowed for selecting.")
      end

      it 'raises exception with invalid sort params' do
        public_send(method, :index, params: { sort: 'invalid_column,destroy,id' }, format: :json)
        expect(json_response).to eq('error' => "Attributes #{%w[invalid_column destroy]} not allowed for sorting.")
      end

      it 'raises exception with invalid filter params' do
        public_send(method, :index, params: { destroy: true, id: 1 }, format: :json)
        expect(json_response).to eq('error' => "Attributes #{%w[destroy]} not allowed for filtering.")
      end
    end

    context 'CSV' do
      it 'raises exception with invalid select params' do
        public_send(method, :index, params: { select: 'invalid_column,destroy,id' }, format: :csv)
        expect(csv_response).to eq([["Attributes #{%w[invalid_column destroy]} not allowed for selecting."]])
      end

      it 'raises exception with invalid sort params' do
        public_send(method, :index, params: { sort: 'invalid_column,destroy,id' }, format: :csv)
        expect(csv_response).to eq([["Attributes #{%w[invalid_column destroy]} not allowed for sorting."]])
      end

      it 'raises exception with invalid filter params' do
        public_send(method, :index, params: { destroy: true, id: 1 }, format: :csv)
        expect(csv_response).to eq([["Attributes #{%w[destroy]} not allowed for filtering."]])
      end
    end
  end
end
