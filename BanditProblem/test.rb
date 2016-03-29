#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

$LOAD_PATH.push(File::dirname($0)) ;
require "pry"
require "yaml"
require 'rubyOkn/BasicTool'
# require 'rubyOkn/StringTool'
require 'rubyOkn/MathTool'

include BasicTool
# include StringTool;
include MathTool;

hash = {}
100000.times do 
  t = GenerateRand.exp().round(1)
if hash[t]== nil  
  hash[t] = 0 ;
else
  hash[t] +=1 ;
end
end

p hash.sort
