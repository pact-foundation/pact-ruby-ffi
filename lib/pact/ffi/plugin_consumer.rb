# require 'pact-ffi/version'
require 'ffi'
require 'pact/detect_os'

module PactFfi
  module PluginConsumer
    extend FFI::Library
    ffi_lib DetectOS.get_bin_path

    # DetectOS.windows? || DetectOS.linux_arm? ? (typedef :uint32, :uint32_type) : (typedef :uint32_t, :uint32_type)
    (typedef :uint32, :uint32_type)

    # /*
    # -1	A null pointer was received
    # -2	The pact JSON could not be parsed
    # -3	The mock server could not be started
    # -4	The method panicked
    # -5	The address is not valid
    # -6	Could not create the TLS configuration with the self-signed certificate
    # */
    CreateMockServerErrors = Hash[
      'NULL_POINTER' => -1,
      'JSON_PARSE_ERROR' => -2,
      'MOCK_SERVER_START_FAIL' => -3,
      'CORE_PANIC' => -4,
      'ADDRESS_NOT_VALID' => -5,
      'TLS_CONFIG' => -6,
    ]

    PluginFunctionResult = Hash[
      'RESULT_OK' => 0,
      'RESULT_FAILED' => 1,
    ]

    attach_function :using_plugin, :pactffi_using_plugin, %i[uint16 string string], :uint32_type
    attach_function :using_plugin_with_delay, :pactffi_using_plugin_with_delay, %i[uint16 string string ulong_long], :uint32_t
    attach_function :cleanup_plugins, :pactffi_cleanup_plugins, %i[uint16], :void
    attach_function :interaction_contents, :pactffi_interaction_contents, %i[uint32_type int32 string string],
                    :uint32_type
    attach_function :add_interaction_reference, :pactffi_add_interaction_reference, %i[uint32_type string string string], :bool
    attach_function :register_plugin_log_callback, :pactffi_register_plugin_log_callback, %i[pointer], :void
    attach_function :get_plugin_logs, :pactffi_get_plugin_logs, %i[string], :string
  end
end
