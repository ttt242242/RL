#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

$LOAD_PATH.push(File::dirname($0)) 
require "pry"
require "yaml"
require 'rubyOkn/BasicTool'
# require 'rubyOkn/StringTool'
require 'BanditAgentQ'
require 'BaseAgent'

include BasicTool
# include StringTool

#
# バンディット問題用のエージェント
#
class BanditAgent < BaseAgent
  attr_accessor :e, :t, :q_table, :selection_method #書き込み、参照可能
  # attr_writer :test #書き込み可能
  # attr_reader :test #参照可能
  def initialize(conf=nil, arm_num)
    conf = make_default_conf() if conf.nil? 
    super(conf) 
    @q_table = create_q_table(conf, arm_num) 
    @selection_method = conf[:selection_method]
    @e = conf[:e] if @selection_method == "e_greedy"
    @t = conf[:t] if @selection_method == "softmax"
  end
  
  def make_default_conf
    conf = {} 
    conf[:e] = 0.01 
    conf[:t] = 0.1 
    conf[:id] = 0 
    conf[:a] = 0.1 

  end
   
  #
  # === Qテーブルの生成
  # @param conf hash 設定hash
  # @return q_table array 生成したQテーブル
  #
  def create_q_table(conf, arm_num)
    q_table = Array.new  
    arm_num.times do |num|
      q_table.push(BanditAgentQ.new(num,0.0)) 
    end
    return q_table 
  end

  #
  # === q値の更新
  #
  def update_q(q_id, reward)
   q_table[q_id].r = @a*reward + (1-@a)*q_table[q_id].r
  end 

  def select_action
    if @selection_method == "e_greedy" 
      e_greedy
    elsif @selection_method == "softmax"
      softmax
    end
  end

  #
  # === egreedyによる行動選択
  # @return action integer 選択した行動
  #
  def e_greedy
    if Random.rand <= self.e
     action = random_select_action 
    else 
     action = greedy_select_action()   
    end
    return action 
  end

  #
  # === ソフトマックス行動選択
  #
  def softmax
    policy_values = {} 
    sum_policy_value = get_sum_policy_value() 
    q_table.each do |q|
      policy_values[q.id] = Math.exp(q.r/self.t) / sum_policy_value  
    end 
  
    rand_value = rand()  # 行動選択を行う際に必要になってくる乱数
    cumlation_iterater = 0.0   # 累積の数で判定を行うので必要
    q_table.size.times do |q_id|
      cumlation_iterater += policy_values[q_id]  
      if rand_value <= cumlation_iterater 
        return q_id 
      end
    end
    return nil    #プログラムに問題あり 
  end 

  #
  # === ソフトマックス法の分母を求めるメソッド
  #
  def get_sum_policy_value
    sum_policy_value = 0.0 
    q_table.each do |q|
      sum_policy_value += Math.exp(q.r/self.t) 
    end 
    return sum_policy_value 
  end
end

#
# 実行用
#
if($0 == __FILE__) then
  
end


