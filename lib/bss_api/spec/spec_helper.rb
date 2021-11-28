require 'test_prof/recipes/rspec/before_all'

Dir[File.join(__dir__, 'support', 'shared_examples', '*.rb')].each { |f| require f }

def json_response
  JSON.parse(response.body)
end

def csv_response
  response.body.each_line.map do |line|
    line.parse_csv
  end
end
