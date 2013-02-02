require 'spec_helper'
require 'css2less'

describe Css2Less do
  it "should have a VERSION constant" do
    subject.const_get('VERSION').should_not be_empty
  end
end
