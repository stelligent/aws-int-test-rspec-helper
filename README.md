# aws-int-test-rspec-helper

## Description

This is just a little bit of code to help make integration testing AWS SDK code more convenient in RSpec. 

To elaborate, it provides a method to create parameterised Cloudformation stacks from [cfndsl](https://github.com/stevenjack/cfndsl)
specifications in the course of an RSpec test.

The idea is to avoid having to write before/setup and after/cleanup code in AWS SDK that is just as complicated as the code under test
(and to avoid the pain of JSON).

## Usage

1. To use it, (after installing the gem) first require it from your `spec_helper.rb`:

        require 'aws-int-test-rspec-helper'

2. Define a cfndsl stack (save as spec/cfndsl_test_templates/security_group_cfndsl.rb).  Note that `vpc_id` isn't defined yet.

        CloudFormation {
          Description 'Create a security group for int testing'
        
          EC2_SecurityGroup('securityGroup1') {
            GroupDescription 'inttest Security Group'
            VpcId vpc_id
          }
        
          Output(:sgId1,
                 Ref('securityGroup1'))
        }

3. Write your test:
    
        require 'awspec'
        context 'security group exists' do
          before(:all) do
            @stack_name = stack(stack_name: 'securitygroupstack',
                                path_to_stack: 'spec/cfndsl_test_templates/security_group_cfndsl.rb',
                                bindings: { vpc_id: 'vpc-12345678' })
          end
        
          it 'does something useful' do
    
            do_something stack_outputs['sgId']
    
            # make some kind of assertion about do_something
            expect(security_group(stack_outputs['sgId'])).to_not be_opened
          end
        
          after(:all) do
            cleanup(@stack_name)
          end
        end

There are a few items of note in the test code:

  * The `stack` method is called in the before block to create the necessary AWS resources
  * The value of the `vpc_id` is passed in through the bindings argument
  * The `path_to_stack` needs to line up with where the cfndsl was saved from step #2.
  * The `stack_outputs` method is used to reference the created security group's id
  * The expectation is using a library [awspec](https://github.com/k1LoW/awspec) to test the features of the security group.
    It does a great job of insulating assertion code from the details of the AWS SDK, making it a bit more
    declarative.
  * The call to `cleanup` in the after removes the created stack
  
## LICENSE

Copyright (c) 2016 Stelligent Systems LLC

MIT LICENSE

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
