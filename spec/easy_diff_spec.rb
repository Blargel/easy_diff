require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require 'yaml'

describe EasyDiff do

  let(:no_diffs) do
    [{},{}]
  end

  it "should do a deep clone" do
    original = {
      "pos" => {:x => 1, :y => 2}
    }

    cloned = original.easy_clone
    cloned.should == original

    cloned["pos"].delete(:x)
    cloned.should_not == original
  end

  # Tests that are dependent on the inputted data. Please edit or add
  # to the test_data.yml file if you have data that breaks the gem.

  test_data_file = File.expand_path(File.dirname(__FILE__) + "/test_data.yml")
  test_data = YAML.load_file test_data_file

  test_data.each do |test_case|
    describe "handling #{test_case["name"]}" do
      let(:original) do
        test_case["original"]
      end

      let(:modified) do
        test_case["modified"]
      end

      it "should compute easy_diff correctly" do
        removed, added = original.easy_diff modified

        removed.should == test_case["expected_removed"]
        added.should == test_case["expected_added"]
      end

      it "should be able to progress original hash to modified hash with no computed diffs" do
        removed, added = original.easy_diff modified

        progressed = original.easy_unmerge(removed).easy_merge(added)

        modified.easy_diff(progressed).should == no_diffs
      end

      it "should be able to reverse modified hash to original hash with no computed diffs" do
        removed, added = original.easy_diff modified

        reversed = modified.easy_unmerge(added).easy_merge(removed)

        original.easy_diff(reversed).should == no_diffs
      end
    end
  end
end
