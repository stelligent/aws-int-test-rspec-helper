require 'aws-int-test-rspec-helper'

describe AwsIntTestRspecHelper do

  it 'creates a stack from cfndsl' do
    # @stack_name = stack(stack_name: 'vanillamadness1',
    #                     path_to_stack: 'spec/test_cfndsl.rb',
    #                     bindings: { bucket_name: 'vanillamadness1' })

    # assert s3 bucket is there
  end

  after(:each) do
    # cleanup(@stack_name)
  end
end