Dir[File.join(__dir__, 'support', 'shared_examples', '*.rb')].each { |f| require f }
require 'test_prof/recipes/minitest/before_all'

def json_response
  JSON.parse(response.body)
end

def csv_response
  response.body.each_line.map do |line|
    line.parse_csv
  end
end
