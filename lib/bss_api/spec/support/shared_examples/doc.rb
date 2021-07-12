RSpec.shared_examples 'BSS: doc' do |api_key|
  before(:each) { request.headers['Authorization'] = api_key }

  it 'returns documentation' do
    get :doc
    expect(response.body).to include('allowed for filter and sort', 'allowed for select', 'filtered by timestamp')
  end
end
