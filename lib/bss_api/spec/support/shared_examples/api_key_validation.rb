RSpec.shared_examples 'BSS: api key validation' do |**requests_params|
  before(:each) { request.headers['Authorization'] = 'invalid_api_key' }

  requests_params.each do |request_params|
    method = request_params[0]
    request_params[1].each do |action|
      context "##{action}" do
        it 'returns 403 code' do
          public_send(method, action)
          expect(response).to have_http_status(:forbidden)
        end

        it 'returns JSON denied error' do
          public_send(method, action, format: :json)
          expect(json_response).to include({ 'error' => 'denied' })
        end

        it 'returns JSON denied error for */* format' do
          public_send(method, action, format: '*/*')
          expect(json_response).to include({ 'error' => 'denied' })
        end

        it 'returns JSON denied error for empty format' do
          public_send(method, action)
          expect(json_response).to include({ 'error' => 'denied' })
        end

        it 'returns CSV denied error' do
          public_send(method, action, format: :csv)
          expect(csv_response).to eq([['Denied error']])
        end
      end
    end
  end
end
