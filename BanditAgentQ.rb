#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

$LOAD_PATH.push(File::dirname($0)) ;
require "pry"
require "yaml"
require 'rubyOkn/BasicTool'
# require 'rubyOkn/StringTool'
require 'Q'

include BasicTool
# include StringTool;

#
# == BanditAgent用のQ値.
#
class BanditAgentQ < Q
  # attr_accessor :test #書き込み、参照可能
  # attr_writer :test #書き込み可能
  # attr_reader :test #参照可能
  def initialize(id=nil,r=0.0)
    super(id, r) ;
  end
end

#
# 実行用
#
if($0 == __FILE__) then
  
end


