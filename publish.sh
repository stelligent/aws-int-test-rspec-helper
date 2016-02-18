#!/bin/bash -ex
set -o pipefail

if [[ -z ${rubygems_api_key} ]];
then
  echo rubygems_api_key must be set in the environment
  exit 1
fi

git config --global user.email "build@build.com"
git config --global user.name "build"

set +e
echo :rubygems_api_key: ${rubygems_api_key} > ~/.gem/credentials
set -e
chmod 0600 ~/.gem/credentials

current_version=$(ruby -e 'tags=`git tag -l v0\.0\.*`' \
                       -e 'p tags.lines.map { |tag| tag.sub(/v0.0./, "").chomp.to_i }.max')

if [[ ${current_version} == nil ]];
then
  new_version='0.0.1'
else
  new_version=0.0.$((current_version+1))
fi

sed -i "s/0\.0\.0/${new_version}/g" aws-int-test-rspec-helper.gemspec

#on circle ci - head is ambiguous for reasons that i don't grok
#we haven't made the new tag and we can't if we are going to annotate
head=$(git log -n 1 --oneline | awk '{print $1}')

echo "Remember! You need to start your commit messages with CS-xx, where x is the issue number your commit resolves."
issue_prefix='^#'

if [[ ${current_version} == nil ]];
then
  log_rev_range=${head}
else
  log_rev_range="v0.0.${current_version}..${head}"
fi

issues=$(git log v0.0.${current_version}..${head} --oneline | awk '{print $2}' | grep '^#' | uniq)

git tag -a v${new_version} -m "Issues with commits, not necessarily closed: ${issues}"

git push --tags

gem build aws-int-test-rspec-helper.gemspec
gem push aws-int-test-rspec-helper-*.gem
