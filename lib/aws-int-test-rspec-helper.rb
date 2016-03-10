require 'aws-sdk'
require 'cfndsl'
require 'rspec'
require 'tempfile'

##
# Some methods to make integration testing AWS SDK code a bit more convenient.
# Easily create AWS resources with cfndsl specifications as part of RSpec tests.
#
module AwsIntTestRspecHelper

  ##
  # Delete the specified Cloudformation stack by name
  #
  def cleanup(cloudformation_stack_name) 
    resource = Aws::CloudFormation::Resource.new
    stack_to_delete = resource.stack(cloudformation_stack_name)

    stack_to_delete.delete
    begin
      stack_to_delete.wait_until(max_attempts:100, delay:15) do |stack|
        stack.stack_status.match /DELETE_COMPLETE/
      end
    rescue
      #squash any errors - when stack is gone, the waiter might freak
    end
  end

  ##
  # Creates a Cloudformation stack.
  #
  # To elaborate, this will create a stack from a cfndsl file and wait until the stack creation is
  # completed (or failed).  You can optionally parameterise the stack with a Hash.
  # The outputs of the stack are available by referencing #stack_outputs.  The return value
  # of the method is the full stack name that is created.
  #
  # * +stack_name+ - a stem for the name of the stack to create.  the final name of the stack
  #                  will be this concatenated with a timestamp
  # * +path_to_stack+ - this is the path to a cfndsl file to create the stack from
  # * +bindings+ - this is an optional Hash of variables that fill in variables in the cfndsl stack
  #                this is how you can parameterise the stack (without Parameters)
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
    created_stack.wait_until(max_attempts:100, delay:15) do |stack|
      stack.stack_status.match /COMPLETE/ or stack.stack_status.match /FAIL/
    end

    @stack_outputs = created_stack.outputs.inject({}) do |hash, output|
      hash[output.output_key] = output.output_value
      hash
    end

    full_stack_name
  end

  ##
  # Returns a Hash of the Cloudformation stack outputs
  #
  def stack_outputs
    @stack_outputs
  end
end

RSpec.configure do |c|
  c.include AwsIntTestRspecHelper
end
