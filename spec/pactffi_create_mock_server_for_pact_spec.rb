require 'httparty'
require 'pact/ffi'
require 'pact/ffi/logger'
require 'pact/ffi/mock_server'
require 'pact/ffi/http_consumer'
require 'fileutils'

PactFfi::Logger.log_to_buffer(PactFfi::Logger::LogLevel['ERROR'])

RSpec.describe 'create_mock_server_for_pact spec' do
  describe 'with matching requests' do
    let(:request_interaction_body) do
      '
      {
        "isbn": {
            "pact:matcher:type": "type",
            "value": "0099740915"
        },
        "title": {
            "pact:matcher:type": "type",
            "value": "The Handmaid\'s Tale"
        },
        "description": {
            "pact:matcher:type": "type",
            "value": "Brilliantly conceived and executed, this powerful evocation of twenty-first century America gives full rein to Margaret Atwood\'s devastating irony, wit and astute perception."
        },
        "author": {
            "pact:matcher:type": "type",
            "value": "Margaret Atwood"
        },
        "publicationDate": {
            "pact:matcher:type": "regex",
            "regex": "^\\\\d{4}-[01]\\\\d-[0-3]\\\\dT[0-2]\\\\d:[0-5]\\\\d:[0-5]\\\\d([+-][0-2]\\\\d:[0-5]\\\\d|Z)$",
            "value": "1985-07-31T00:00:00+00:00"
        }
      }
      '
    end
    let(:response_interaction_body) do
      '
      {
        "@context": "/api/contexts/Book",
        "@id": {
            "pact:matcher:type": "regex",
            "regex": "^\\\\/api\\\\/books\\\\/[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$",
            "value": "/api/books/0114b2a8-3347-49d8-ad99-0e792c5a30e6"
        },
        "@type": "Book",
        "title": {
            "pact:matcher:type": "type",
            "value": "Voluptas et tempora repellat corporis excepturi."
        },
        "description": {
            "pact:matcher:type": "type",
            "value": "Quaerat odit quia nisi accusantium natus voluptatem. Explicabo corporis eligendi ut ut sapiente ut qui quidem. Optio amet velit aut delectus. Sed alias asperiores perspiciatis deserunt omnis. Mollitia unde id in."
        },
        "author": {
            "pact:matcher:type": "type",
            "value": "Melisa Kassulke"
        },
        "publicationDate": {
            "pact:matcher:type": "regex",
            "regex": "^\\\\d{4}-[01]\\\\d-[0-3]\\\\dT[0-2]\\\\d:[0-5]\\\\d:[0-5]\\\\d([+-][0-2]\\\\d:[0-5]\\\\d|Z)$",
            "value": "1999-02-13T00:00:00+07:00"
        },
        "reviews": [

        ]
      }
      '
    end

    let(:mock_server_port) { PactFfi::MockServer.create_for_transport(pact, '127.0.0.1', 0, 'http', nil) }
    let(:pact) { PactFfi.new_pact('http-consumer-1', 'http-provider') }
    let(:interaction) { PactFfi::HttpConsumer.new_interaction(pact, 'A POST request to create book') }

    before do
      PactFfi::HttpConsumer.with_specification(pact, PactFfi::FfiSpecificationVersion['SPECIFICATION_VERSION_V3'])
      PactFfi::HttpConsumer.upon_receiving(interaction, 'A POST request to create book')
      PactFfi::HttpConsumer.given(interaction, 'No book fixtures required')
      PactFfi::HttpConsumer.with_request(interaction, 'POST', '/api/books')
      PactFfi::HttpConsumer.with_header(interaction, PactFfi::FfiInteractionPart['INTERACTION_PART_REQUEST'],
                                   'Content-Type', 0, 'application/json')
      PactFfi::HttpConsumer.with_body(interaction, PactFfi::FfiInteractionPart['INTERACTION_PART_REQUEST'],
                                 'application/json', request_interaction_body)
      PactFfi::HttpConsumer.response_status(interaction, 201)
      PactFfi::HttpConsumer.with_header(interaction, PactFfi::FfiInteractionPart['INTERACTION_PART_RESPONSE'],
                                   'Content-Type', 0, 'application/ld+json; charset=utf-8')
      PactFfi::HttpConsumer.with_body(interaction, PactFfi::FfiInteractionPart['INTERACTION_PART_RESPONSE'],
                                 'application/ld+json; charset=utf-8', response_interaction_body)
    end
    after do
      expect(PactFfi::MockServer.matched(mock_server_port)).to be true
      res_write_pact = PactFfi::MockServer.write_pact_file(mock_server_port, './pacts', false)
      PactFfi::MockServer.cleanup(mock_server_port)
      expect(res_write_pact).to be(0)
    end

    it 'executes the pact test with no errors' do
      puts "Mock server port=#{mock_server_port}"

      options = {

        body: {
          isbn: '0099740915',
          title: "The Handmaid's Tale",
          description: 'Brilliantly conceived and executed, this powerful evocation of twenty-first century America gives full rein to Margaret Atwood\'s devastating irony, wit and astute perception.',
          author: 'Margaret Atwood',
          publicationDate: '1985-07-31T00:00:00+00:00'
        },
        # body: {
        #   isbn: '0099740915',
        #   title: 123,
        #   description: 'Natus ut doloribus magni. Impedit aperiam ea similique. Sed architecto quod nulla maxime. Quibusdam inventore esse harum accusantium rerum nulla voluptatem.',
        #   author: 'Maryse Kulas',
        #   publicationDate: 'tommorow'
        # },
        params: {
          hostname: '127.0.0.1',
          path: '/api/books',
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          }
        }
      }
      response = HTTParty.post("http://#{options[:params][:hostname]}:#{mock_server_port}#{options[:params][:path]}", {
                                 body: options[:body].to_json,
                                 headers: { 'Content-Type' => 'application/json' }
                               })

      expect(response.body).to eq '{"@context":"/api/contexts/Book","@id":"/api/books/0114b2a8-3347-49d8-ad99-0e792c5a30e6","@type":"Book","author":"Melisa Kassulke","description":"Quaerat odit quia nisi accusantium natus voluptatem. Explicabo corporis eligendi ut ut sapiente ut qui quidem. Optio amet velit aut delectus. Sed alias asperiores perspiciatis deserunt omnis. Mollitia unde id in.","publicationDate":"1999-02-13T00:00:00+07:00","reviews":[],"title":"Voluptas et tempora repellat corporis excepturi."}'
    end
  end
  describe 'with mismatching requests' do
    let(:request_interaction_body) do
      '
      {
        "isbn": {
            "pact:matcher:type": "type",
            "value": "0099740915"
        },
        "title": {
            "pact:matcher:type": "type",
            "value": "The Handmaid\'s Tale"
        },
        "description": {
            "pact:matcher:type": "type",
            "value": "Brilliantly conceived and executed, this powerful evocation of twenty-first century America gives full rein to Margaret Atwood\'s devastating irony, wit and astute perception."
        },
        "author": {
            "pact:matcher:type": "type",
            "value": "Margaret Atwood"
        },
        "publicationDate": {
            "pact:matcher:type": "regex",
            "regex": "^\\\\d{4}-[01]\\\\d-[0-3]\\\\dT[0-2]\\\\d:[0-5]\\\\d:[0-5]\\\\d([+-][0-2]\\\\d:[0-5]\\\\d|Z)$",
            "value": "1985-07-31T00:00:00+00:00"
        }
      }
      '
    end
    let(:response_interaction_body) do
      '
      {
        "@context": "/api/contexts/Book",
        "@id": {
            "pact:matcher:type": "regex",
            "regex": "^\\\\/api\\\\/books\\\\/[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$",
            "value": "/api/books/0114b2a8-3347-49d8-ad99-0e792c5a30e6"
        },
        "@type": "Book",
        "title": {
            "pact:matcher:type": "type",
            "value": "Voluptas et tempora repellat corporis excepturi."
        },
        "description": {
            "pact:matcher:type": "type",
            "value": "Quaerat odit quia nisi accusantium natus voluptatem. Explicabo corporis eligendi ut ut sapiente ut qui quidem. Optio amet velit aut delectus. Sed alias asperiores perspiciatis deserunt omnis. Mollitia unde id in."
        },
        "author": {
            "pact:matcher:type": "type",
            "value": "Melisa Kassulke"
        },
        "publicationDate": {
            "pact:matcher:type": "regex",
            "regex": "^\\\\d{4}-[01]\\\\d-[0-3]\\\\dT[0-2]\\\\d:[0-5]\\\\d:[0-5]\\\\d([+-][0-2]\\\\d:[0-5]\\\\d|Z)$",
            "value": "1999-02-13T00:00:00+07:00"
        },
        "reviews": [

        ]
      }
      '
    end

    let(:mock_server_port) { PactFfi::MockServer.create_for_transport(pact, '127.0.0.1', 0, 'http', nil) }
    let(:pact) { PactFfi.new_pact('http-consumer-1', 'http-provider') }
    let(:interaction) { PactFfi::HttpConsumer.new_interaction(pact, 'A POST request to create book') }
    before do
      PactFfi::HttpConsumer.with_specification(pact, PactFfi::FfiSpecificationVersion['SPECIFICATION_VERSION_V3'])
      PactFfi::HttpConsumer.upon_receiving(interaction, 'A POST request to create book')
      PactFfi::HttpConsumer.given(interaction, 'No book fixtures required')
      PactFfi::HttpConsumer.with_request(interaction, 'POST', '/api/books')
      PactFfi::HttpConsumer.with_header(interaction, PactFfi::FfiInteractionPart['INTERACTION_PART_REQUEST'],
                                   'Content-Type', 0, 'application/json')
      PactFfi::HttpConsumer.with_body(interaction, PactFfi::FfiInteractionPart['INTERACTION_PART_REQUEST'],
                                 'application/json', request_interaction_body)
      PactFfi::HttpConsumer.response_status(interaction, 201)
      PactFfi::HttpConsumer.with_header(interaction, PactFfi::FfiInteractionPart['INTERACTION_PART_RESPONSE'],
                                   'Content-Type', 0, 'application/ld+json; charset=utf-8')
      PactFfi::HttpConsumer.with_body(interaction, PactFfi::FfiInteractionPart['INTERACTION_PART_RESPONSE'],
                                 'application/ld+json; charset=utf-8', response_interaction_body)
    end
    after do
      expect(PactFfi::MockServer.matched(mock_server_port)).to be false
      mismatchers = PactFfi::MockServer.mismatches(mock_server_port)
      puts JSON.parse(mismatchers)
      expect(JSON.parse(mismatchers).length).to eql(1)
      PactFfi::MockServer.cleanup(mock_server_port)
    end

    it 'executes the pact test with errors' do
      puts "Mock server port=#{mock_server_port}"

      options = {

        body: {
          isbn: '0099740915',
          title: 123,
          description: 'Natus ut doloribus magni. Impedit aperiam ea similique. Sed architecto quod nulla maxime. Quibusdam inventore esse harum accusantium rerum nulla voluptatem.',
          author: 'Maryse Kulas',
          publicationDate: 'tommorow'
        },
        params: {
          hostname: '127.0.0.1',
          path: '/api/books',
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          }
        }
      }
      response = HTTParty.post("http://#{options[:params][:hostname]}:#{mock_server_port}#{options[:params][:path]}", {
                                 body: options[:body].to_json,
                                 headers: { 'Content-Type' => 'application/json' }
                               })
    end
  end
end
