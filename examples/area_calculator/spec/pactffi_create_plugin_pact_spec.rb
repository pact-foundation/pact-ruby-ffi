require 'pact/ffi'
require 'pact/ffi/mock_server'
require 'pact/ffi/sync_message_consumer'
require 'pact/ffi/logger'
require 'pact/ffi/plugin_consumer'
require_relative '../area_calculator_consumer'
include AreaCalculatorConsumer
require 'grpc'

RSpec.describe 'pactffi_new_plugin spec' do
  # unskip so this test runs, it will fail verification correctly on the provider side (method not implemented)
  describe 'with grpcInteraction - calculateMulti' do
    let(:contents) do
      {
        "pact:proto": File.expand_path('./proto/area_calculator.proto'),
        "pact:proto-service": 'Calculator/calculateMulti',
        "pact:content-type": 'application/protobuf',
        "request": {
          "shapes": [
            {
              "rectangle": {
                "length": 'matching(number, 3)',
                "width": 'matching(number, 4)'
              }
            },
            {
              "square": {
                "edge_length": 'matching(number, 3)'
              }
            }
          ]
        },
        "response": {
          "value": ['matching(number, 12)', 'matching(number, 9)']
        }
      }
    end

    let(:pact) do
      PactFfi.init
      PactFfi.new_pact('grpc-consumer-ruby', 'area-calculator-provider')
    end
    let(:message_pact) do
      PactFfi::SyncMessageConsumer.new_interaction(pact, 'pact desc')
    end
    let(:spec_version) do
      PactFfi::MockServer.with_specification(pact, PactFfi::FfiSpecificationVersion['SPECIFICATION_VERSION_V4'])
    end
    let(:mock_server_port) { PactFfi::MockServer.create_for_transport(pact, '127.0.0.1', 0, 'grpc', nil) }

    before do
      PactFfi.with_pact_metadata(pact, 'pact-ruby', 'ffi', PactFfi.version)
      PactFfi::Logger.log_to_stdout(PactFfi::FfiLogLevelFilter['LOG_LEVEL_INFO'])
      PactFfi::Logger.message('pact_ruby', 'INFO', 'pact ruby grpc is alive')
      PactFfi::PluginConsumer.using_plugin(pact, 'protobuf', '0.4.0')
    end
    after do
      matched = PactFfi::MockServer.matched(mock_server_port)
      if matched == true
        res_write_pact = PactFfi::MockServer.write_pact_file(mock_server_port, './pacts', false)
        if res_write_pact.zero?
          puts 'pact file generated'
        else
          puts "Failed to write pact file: #{res_write_pact}"
        end
      else
        mismatches = PactFfi::MockServer.mismatches(mock_server_port)
        if JSON.parse(mismatches).length.zero?
          raise 'the mock server returned matched false, but there are no mismatches to report, this shouldn\t be the case'
        end
        puts JSON.parse(mismatches)
      end
      PactFfi::MockServer.cleanup(mock_server_port)
      expect(matched).to be(false)
      # Should this be using write message pact
      # res_write_message_pact =PactFfi::MockServer.write_message_pact_file(message_pact, './pacts', false)
      # puts "res_write_message_pact: #{res_write_message_pact}"
    end
    it 'executes the pact test with errors' do
      PactFfi::PluginConsumer.interaction_contents(message_pact, 0, 'application/grpc', JSON.dump(contents))
    end
  end
  describe 'with grpcInteraction - calculateOne' do
    let(:contents) do
      {
        "pact:proto": File.expand_path('./proto/area_calculator.proto'),
        "pact:proto-service": 'Calculator/calculateOne',
        "pact:content-type": 'application/protobuf',
        "request": {
          "rectangle": {
            "length": 'matching(number, 3)',
            "width": 'matching(number, 4)'
          }
        },
        "response": {
          "value": ['matching(number, 12)']
        }
      }
    end

    let(:pact) do
      PactFfi.init
      PactFfi.new_pact('grpc-consumer-ruby', 'area-calculator-provider')
    end
    let(:message_pact) do
     PactFfi::SyncMessageConsumer.new_interaction(pact, 'pact calc 2')
    end
    let(:spec_version) do
     PactFfi::MockServer.with_specification(pact, PactFfi::FfiSpecificationVersion['SPECIFICATION_VERSION_V4'])
    end
    let(:mock_server_port) { PactFfi::MockServer.create_for_transport(pact, '127.0.0.1', 0, 'grpc', nil) }

    before do
      PactFfi.with_pact_metadata(pact, 'pact-ruby', 'ffi', PactFfi.version)
      PactFfi::Logger.log_to_stdout(PactFfi::FfiLogLevelFilter['LOG_LEVEL_INFO'])
      PactFfi::Logger.message('pact_ruby', 'INFO', 'pact ruby grpc is alive')
      PactFfi::PluginConsumer.using_plugin(pact, 'protobuf', '0.4.0')
    end
    after do
      matched = PactFfi::MockServer.matched(mock_server_port)
      if matched == true
        res_write_pact = PactFfi::MockServer.write_pact_file(mock_server_port, './pacts', false)
        if res_write_pact.zero?
          puts 'pact file generated'
        else
          puts "Failed to write pact file: #{res_write_pact}"
        end
      else
        mismatches = PactFfi::MockServer.mismatches(mock_server_port)
        if JSON.parse(mismatches).length.zero?
          raise 'the mock server returned matched false, but there are no mismatches to report, this shouldn\t be the case'
        end
        puts JSON.parse(mismatches)
      end
      PactFfi::MockServer.cleanup(mock_server_port)
      expect(matched).to be(true)
    end
    it 'executes the pact test without errors' do
     PactFfi::PluginConsumer.interaction_contents(message_pact, 0, 'application/grpc', JSON.dump(contents))
      res = AreaCalculatorConsumer.get_rectangle_area("localhost:#{mock_server_port}")
      expect(res).to eq([12.0])
    end
  end
end

# Interaction key hash is different per run, so if the same tests are run cross platform, one will stop the other publishing
# have generated with os specific names now
# Cannot change the content of the pact for area-calculator-provider version eceded2424b2e59d7c6f330ff04d2c56ff65419f and provider area-calculator-provider, as race conditions will cause unreliable results for can-i-deploy. Each pact must be published with a unique consumer version number. For more information see https://docs.pact.io/go/versioning
#  {
#   "interactions": [
#     {
# -      "key": "d7bc9ed1be359d82"
# +      "key": "3b4b1d4448b3e96f"
#     }
#   ]
# }
