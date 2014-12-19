require File.expand_path(File.dirname(__FILE__) + '/easy_diff/safe_dup')
require File.expand_path(File.dirname(__FILE__) + '/easy_diff/core')
require File.expand_path(File.dirname(__FILE__) + '/easy_diff/hash_ext')

Object.send :include, EasyDiff::SafeDup
Hash.send :include, EasyDiff::HashExt
