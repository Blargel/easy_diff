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
   @original.should == {
      :tags => ['a', 'b', 'c'],
      :pos => {:x => '1', :y => '2'},
      :some_str => "bla",
      :some_int => 1,
      :some_bool => false,
      :extra_removed => "bye"
    }
  end

  it "should stay the same" do
    removed, added = @original.easy_diff @modified
    unmerged = @modified.easy_unmerge added
    original = unmerged.easy_merge removed
    original.should == @original
  end

  it "should do a deep clone" do
    cloned = @original.easy_clone
    cloned.should == @original
    cloned[:tags] << 'd'
    cloned[:pos][:x] = '2'
    cloned.should == {
      :tags => ['a', 'b', 'c', 'd'],
      :pos => {:x => '2', :y => '2'},
      :some_str => "bla",
      :some_int => 1,
      :some_bool => false,
      :extra_removed => "bye"
    }
    @original.should == {
      :tags => ['a', 'b', 'c'],
      :pos => {:x => '1', :y => '2'},
      :some_str => "bla",
      :some_int => 1,
      :some_bool => false,
      :extra_removed => "bye"
    }
  end

  it "should not show empty hashes or arrays as diffs" do
    @modified[:tags] = @original[:tags]
    @modified[:pos] = @original[:pos]
    @removed.delete :pos
    @removed.delete :tags
    @added.delete :pos
    @added.delete :tags
    removed, added = @original.easy_diff @modified
    removed.should == @removed
    added.should == @added
  end

  it "should show added empty hashes as a diff" do
    @original[:empty_array] = []
    @modified[:empty_hash] = {}
    @removed[:empty_array] = []
    @added[:empty_hash] = {}
    removed, added = @original.easy_diff @modified
    removed.should == @removed
    added.should == @added
  end

  it "should only check empty? on Hashes and Arrays" do
    original = {:possibly_empty_string => ""}
    modified = {:possibly_empty_string => "not empty"}
    removed, added = original.easy_diff modified
    removed.should == {:possibly_empty_string => ""}
    added.should == {:possibly_empty_string => "not empty"}
  end

  describe 'handling Arrays containing Hashes' do
    let(:original) do
      {
        "key" => [
          {"c" => "1"},
          {"a" => "2"},
          {"a" => "1"},
        ]
      }
    end

    it "should merge properly" do
      to_merge = {
        "key" => [
          {"b" => "2"},
        ]
      }

      merged = original.easy_merge to_merge
      merged.should == {
        "key" => [
          {"a" => "1"},
          {"a" => "2"},
          {"b" => "2"},
          {"c" => "1"},
        ]
      }
    end

    it "should unmerge properly" do
      to_unmerge = {
        "key" => [
          {"a" => "2"},
        ]
      }

      unmerged = original.easy_unmerge to_unmerge
      unmerged.should == {
        "key" => [
          {"a" => "1"},
          {"c" => "1"},
        ]
      }
    end
  end

  describe 'handling Arrays containing Hashes with nils' do
    let(:original) do
      {
        "key" => [
          { "a" => "1", "b" => "2" },
          { "a" => nil, "c" => "2" },
          { "e" => "5" },
        ]
      }
    end

    it "should merge without errors" do
      to_merge = {
        "key" => [
          { "d" => "4" },
        ]
      }
      expect { original.easy_merge(to_merge) }.to_not raise_error
    end

    it "should unmerge without errors" do
      to_unmerge = {
        "key" => [
          { "e" => "5" },
        ]
      }

      unmerged = original.easy_unmerge to_unmerge
      unmerged.should == {
        "key" => [
          { "a" => "1", "b" => "2" },
          { "a" => nil, "c" => "2" },
        ]
      }
    end
  end
end
