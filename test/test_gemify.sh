#!/bin/sh

# The gemification step is tricky to test. =\

sudo gem uninstall -x dummy
rm -rf /tmp/dummy-instance
rm -rf /tmp/dummy

cd /tmp
rails dummy
cd /tmp/dummy
script/generate scaffold Dummy name:string favourite_dumb_thing:string
harker
rake install_gem
dummy init /tmp/dummy-instance
cd /tmp/dummy-instance
dummy migrate
dummy start
