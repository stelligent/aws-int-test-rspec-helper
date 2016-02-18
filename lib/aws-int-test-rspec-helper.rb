require 'aws-sdk'
require 'cfndsl'
require 'rspec'

module AwsIntTestRspecHelper

  def cleanup(cloudformation_stack_name)
    Aws::CloudFormation::Client.new.delete_stack(stack_name: cloudformation_stack_name)
  end

  def stack(stack_name:,
            path_to_stack:,
            bindings: nil)

    full_stack_name = "#{stack_name}#{Time.now.to_i}"

    extras = []
    unless bindings.nil?
      temp_file = Tempfile.new('cfnstackfortesting')
      temp_file.write bindings.to_yaml
      temp_file.close

      extras << [:yaml,File.expand_path(temp_file)]
    end

    verbose = false
    model = CfnDsl::eval_file_with_extras(File.expand_path(path_to_stack),
                                          extras,
                                          verbose)

    resource = Aws::CloudFormation::Resource.new
    created_stack = resource.create_stack(stack_name: full_stack_name,
                                          template_body: model.to_json,
                                          disable_rollback: true,
                                          capabilities: %w{CAPABILITY_IAM})

    #need to provide more details to the waiter - or deal with more stack outcomes?
    created_stack.wait_until(max_attempts:100, delay:15) {|stack| stack.stack_status == 'CREATE_COMPLETE' }

    @stack_outputs = created_stack.outputs.inject({}) do |hash, output|
      hash[output.output_key] = output.output_value
      hash
    end

    full_stack_name
  end


  def stack_outputs
    @stack_outputs
  end
end

RSpec.configure do |c|
  c.include AwsIntTestRspecHelper
end
