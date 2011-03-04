require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe EasyDiff do
  before :each do
    @original = {
      :tags => ['a', 'b', 'c'],
      :pos => {:x => '1', :y => '2'},
      :some_str => "bla",
      :some_int => 1,
      :some_bool => false,
      :extra_removed => "bye"
    }
    
    @modified = {
      :tags => ['b', 'c', 'd'],
      :pos => {:x => '3', :y => '2'},
      :some_str => "bla",
      :some_int => 2,
      :some_bool => true,
      :extra_added => "hi"
    }
    
    @removed = {
      :tags => ['a'],
      :pos => {:x => '1'},
      :some_int => 1,
      :some_bool => false,
      :extra_removed => "bye"
    }
    
    @added = {
      :tags => ['d'],
      :pos => {:x => '3'},
      :some_int => 2,
      :some_bool => true,
      :extra_added => "hi"
    }
  end
  it "should compute easy_diff" do
    removed, added = @original.easy_diff @modified
    removed.should == @removed
    added.should == @added
  end
  
  it "should compute easy_unmerge" do
    unmerged = @modified.easy_unmerge @added
    unmerged.should == {
      :tags => ['b', 'c'],
      :pos => {:y => '2'},
      :some_str => "bla"
    }
  end
  
  it "should compute easy_merge" do
   merged = @original.easy_merge @added
   merged.should == {
     :tags => ['a', 'b', 'c', 'd'],
     :pos => {:x => '3', :y => '2'},
     :some_str => "bla",
     :some_int => 2,
     :some_bool => true,
     :extra_removed => "bye",
     :extra_added => "hi"
   }
  end
  
  it "should stay the same" do
    removed, added = @original.easy_diff @modified
    unmerged = @modified.easy_unmerge added
    original = unmerged.easy_merge removed
    original.should == @original
  end
end
