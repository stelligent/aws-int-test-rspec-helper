import boto3
from aloisius import Stack
import aloisius
import time


class aws_integration_test(object):
  def __init__(self,
               path_to_initial_condition_cfn_template,
               stack_name=None,
               teardown=False):
    self.path_to_initial_condition_cfn_template = path_to_initial_condition_cfn_template
    self.stack_name = stack_name
    self.teardown = teardown

  def __call__(self, test_function):
    def decorated_test_function(*args):
      import os
      dir = os.path.dirname(__file__)

      with open(os.path.join(dir, self.path_to_initial_condition_cfn_template), 'r') as initial_condition_cfn_template_file:
        initial_condition_cfn_template_content = initial_condition_cfn_template_file.read()

      qualified_stack_name = self._stack_name(self.stack_name)

      Stack(
        StackName=qualified_stack_name,
        TargetState='present',
        RegionName='us-east-1',
        TemplateBody=initial_condition_cfn_template_content,
      )
      aloisius.stacks.wait()
      if not aloisius.stacks.success():
        raise Exception(f'{qualified_stack_name} did not converge')

      # self.stack_outputs = self._collect_stack_outputs_as_dict(aloisius.stacks)

      test_function(*args) # StackOutputs=self.stack_outputs)

      if self.teardown == True:
        Stack(
          StackName=qualified_stack_name,
          TargetState='absent',
          RegionName='us-east-1',
          TemplateBody=initial_condition_cfn_template_content,
        )

    return decorated_test_function

  def _stack_name(self, stack_name):
    return f'{stack_name}{self._now()}'

  def _now(self):
    return int(round(time.time() * 1000))

  def _collect_stack_outputs_as_dict(self, stacks):
    outputs = {}
    for stack in stacks:
      for key, value in stack.outputs.items():
        outputs[key] = value
    return outputs

