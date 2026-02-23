require 'net/http'
require 'uri'
require 'webrick'
require 'pact/ffi/verifier'
require 'pact/ffi/logger'
require 'json'
PactFfi::Logger.log_to_stdout(PactFfi::Logger::LogLevel['INFO'])
RSpec.describe 'pactffi verifier spec' do
  before(:all) do
    # running in process, results in requests only hitting server when verification complete
    @pid = Process.spawn('ruby provider.rb')
    puts @pid
    # Check server is up
    uri = URI.parse('http://localhost:8000/api/books')
    response = nil
    100.times do # long sleep due to delays under qemu in ci
      response = Net::HTTP.get_response(uri)
      break if response.code == '404'
    rescue Errno::ECONNREFUSED
      sleep(1)
    end
    if response && response.code == '404'
      puts 'Healthcheck passed'
    else
      puts 'Healthcheck failed'
    end
  end
  after(:all) do
    puts @pid
    Process.kill('SIGKILL', @pid)
    Process.wait(@pid)
  end
  let(:verifier) { PactFfi::Verifier.new_for_application('pact-ruby', '1.0.0') }
  after do
    PactFfi::Verifier.shutdown(verifier)
    # @server_thread.kill
  end
  it 'should respond verify with pact' do
    PactFfi::Verifier.set_provider_info(verifier, 'http-provider', 'http', nil, 8000, '/')
    PactFfi::Verifier.add_file_source(verifier,
                                      'pacts/http-consumer-1-http-provider.json')
    result = PactFfi::Verifier.execute(verifier)
    expect(result).to eq(PactFfi::Verifier::Response['VERIFICATION_SUCCESSFUL'])
  end

  it 'should allow setting follow redirects' do
    # Test that the function can be called without error
    # Setting to 0 (false) should disable redirects
    PactFfi::Verifier.set_follow_redirects(verifier, 0)
    # Setting to 1 (true) should enable redirects
    PactFfi::Verifier.set_follow_redirects(verifier, 1)
  end
end
