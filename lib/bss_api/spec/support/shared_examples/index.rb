RSpec.shared_examples 'BSS: index' do |api_key, methods:, subject_name:, factory:, decorator: nil,
                                       pattern_fields: [], select_fields: []|
  let!(:record1) { create(factory) }
  let!(:record2) { create(factory) }
  let!(:record3) { create(factory) }
  let!(:record4) { create(factory) }
  collection_name = subject_name.to_s.pluralize
  model_id = "#{subject_name}_id"
  select_fields_string = select_fields.join(',')
  before(:each) { request.headers['Authorization'] = api_key }

  methods.each do |method|
    context "#{method.upcase} #index" do
      context 'CSV request' do
        before(:each) { request.headers['Content-Type'] = 'text/csv' }

        it 'returns csv collection with given ids' do
          body =
            "
            #{record1.id}
            #{record2.id}
            "
          public_send(method, :index, params: { select: 'id', sort: 'id' }, body: body, format: :csv)
          expect(csv_response).to eq([
                                       [record1.id.to_s],
                                       [record2.id.to_s]
                                     ])
        end

        it 'returns json collection with given ids' do
          body =
            "
            #{record1.id}
            #{record2.id}
            "
          public_send(method, :index, params: { select: 'id', sort: 'id' }, body: body, format: :json)
          expect(json_response).to eq(
                                     collection_name => [
                                       { 'id' => record1.id },
                                       { 'id' => record2.id }
                                     ]
                                   )
        end
      end

      context 'CSV response' do
        it 'selects collection' do
          public_send(method, :index, params: { select: 'id', sort: 'id' }, format: :csv)
          expect(csv_response).to eq([
                                       [record1.id.to_s],
                                       [record2.id.to_s],
                                       [record3.id.to_s],
                                       [record4.id.to_s]
                                     ])
        end

        it 'selects and sorts collection' do
          public_send(method, :index, params: { select: 'id', sort: '-id' }, format: :csv)
          expect(csv_response).to eq([
                                       [record4.id.to_s],
                                       [record3.id.to_s],
                                       [record2.id.to_s],
                                       [record1.id.to_s]
                                     ])
        end

        it 'selects and filters collection' do
          public_send(method, :index, params: { select: 'id', sort: 'id', id_ne: record1.id }, format: :csv)
          expect(csv_response).to eq([
                                       [record2.id.to_s],
                                       [record3.id.to_s],
                                       [record4.id.to_s]
                                     ])
        end

        it 'selects, sorts and filters users' do
          public_send(method, :index, params: { select: 'id', sort: '-id', id_ne: record1.id }, format: :csv)
          expect(csv_response).to eq([
                                       [record4.id.to_s],
                                       [record3.id.to_s],
                                       [record2.id.to_s]
                                     ])
        end

        it "selects and filters users with #{model_id} param" do
          public_send(method, :index, params: { select: 'id', model_id => record1.id }, format: :csv)
          expect(csv_response).to eq([[record1.id.to_s]])
        end

        pattern_fields.each do |patter_field|
          it "selects users by #{patter_field} pattern" do
            public_send(method, :index,
                        params: { select: 'id', patter_field => record3.public_send(patter_field)[1...-1] },
                        format: :csv)
            expect(csv_response).to eq([[record3.id.to_s]])
          end
        end

        if select_fields.any? && decorator
          it 'selects users additional methods' do
            public_send(method, :index, params: { select: select_fields_string, id: record2.id }, format: :csv)
            record2.extend(decorator)
            expect(csv_response).to eq([select_fields.map { |f| record2.public_send(f)&.to_s }])
          end
        end
      end

      context 'JSON response' do
        it 'selects collection' do
          public_send(method, :index, params: { select: 'id', sort: 'id' }, format: :json)
          expect(json_response).to eq(
                                     collection_name => [
                                       { 'id' => record1.id },
                                       { 'id' => record2.id },
                                       { 'id' => record3.id },
                                       { 'id' => record4.id }
                                     ]
                                   )
        end

        it 'selects and sorts collection' do
          public_send(method, :index, params: { select: 'id', sort: '-id' }, format: :json)
          expect(json_response).to eq(
                                     collection_name => [
                                       { 'id' => record4.id },
                                       { 'id' => record3.id },
                                       { 'id' => record2.id },
                                       { 'id' => record1.id }
                                     ]
                                   )
        end

        it 'selects and filters users' do
          public_send(method, :index, params: { select: 'id', sort: 'id', id_ne: record1.id }, format: :json)
          expect(json_response).to eq(
                                     collection_name => [
                                       { 'id' => record2.id },
                                       { 'id' => record3.id },
                                       { 'id' => record4.id }
                                     ]
                                   )
        end

        it 'selects, sorts and filters users' do
          public_send(method, :index, params: { select: 'id', sort: '-id', id_ne: record1.id }, format: :json)
          expect(json_response).to eq(
                                     collection_name => [
                                       { 'id' => record4.id },
                                       { 'id' => record3.id },
                                       { 'id' => record2.id }
                                     ]
                                   )
        end

        it "selects and filters users with #{model_id} param" do
          public_send(method, :index, params: { select: 'id', model_id => record1.id }, format: :json)
          expect(json_response).to eq(
                                     collection_name => [
                                       { 'id' => record1.id }
                                     ]
                                   )
        end

        pattern_fields.each do |patter_field|
          it "selects users by #{patter_field} pattern" do
            public_send(method, :index,
                        params: { select: 'id', patter_field => record3.public_send(patter_field)[1...-1] },
                        format: :json)
            expect(json_response).to eq(
                                      collection_name => [
                                        { 'id' => record3.id }
                                      ]
                                    )
          end
        end

        if select_fields.any? && decorator
          it 'selects users additional methods' do
            public_send(method, :index, params: { select: select_fields_string, id: record2.id }, format: :json)
            record2.extend(decorator)
            expected_result = Hash[select_fields.map { |f| [f.to_s, record2.public_send(f)] }]
            expect(json_response).to eq(
                                       collection_name => [
                                         expected_result
                                       ]
                                     )
          end
        end
      end

      context '*/* format' do
        it 'returns json' do
          public_send(method, :index, params: { select: 'id', sort: '-id' }, format: '*/*')
          expect(json_response).to eq(
                                     collection_name => [
                                       { 'id' => record4.id },
                                       { 'id' => record3.id },
                                       { 'id' => record2.id },
                                       { 'id' => record1.id }
                                     ]
                                   )
        end
      end

      context 'without format' do
        it 'returns json' do
          public_send(method, :index, params: { select: 'id', sort: '-id' })
          expect(json_response).to eq(
                                     collection_name => [
                                       { 'id' => record4.id },
                                       { 'id' => record3.id },
                                       { 'id' => record2.id },
                                       { 'id' => record1.id }
                                     ]
                                   )
        end
      end
    end
  end
end
