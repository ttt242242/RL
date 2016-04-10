#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

$LOAD_PATH.push(File::dirname($0)) ;
require "pry"
require "yaml"
require 'rubyOkn/BasicTool'
require 'rubyOkn/MathTool'
require 'rubyOkn/GenerateGraph'
require 'BanditAgent'

include BasicTool
include MathTool

#
# == バンディットクラス
#
class Bandit
  attr_accessor :arms, :conf ;   #書き込み、参照可能

  #
  # == armクラス
  #
  class Arm
    attr_accessor :ave, :var ;   #書き込み、参照可能
    #
    # === 確率分布の種類, 種類毎にconfに設定してあるデータで
    #
    def initialize(arm_conf)
     initialize_arm(arm_conf) 
    end
   
    #
    # === 各確率分布種類毎に分ける
    #
    def initialize_arm(arm_conf)
      if arm_conf[:dis] == "exp"
        @ave = arm_conf[:ave]  ;
      end
    end

    def pull_lever()
      # return GenerateRand.exp(@ave) ;
      return @ave ;
    end
  end


  def initialize(conf=nil)
    if conf.nil?
      @conf = make_default_conf() ;
    else
      @conf = conf ;
    end
    @arms = [] ;  #レバ-
    initialize_arms() ; #レバーの初期化
  end

  def make_default_conf()
    conf = {} ;
    conf[:arm_num] = 6 ;
    return conf ;
  end

  #
  # === レバーの初期化
  #
  def initialize_arms()
    ave = 0.0 ;
    @conf[:arm_num].times do 
      arm_conf = make_default_arm_conf(ave) ;
      @arms.push(Arm.new(arm_conf)) ;
      ave +=0.3
    end
  end

  def make_default_arm_conf(ave=0.5)
    arm_conf = {} ;
    arm_conf[:dis] = "exp" ;
    arm_conf[:ave] = ave ;
    return arm_conf ;
  end

  #
  # === レバーを引く
  # @param lever_num integer 選択したレバーのid
  # @return reward float 報酬
  #
  def pull_lever(lever_num)
    # output reward by a disttribution
    arm = @arms[lever_num] ;
    return arm.pull_lever ;
  end 

end

#
# 実行用
#
if($0 == __FILE__) then
  agent_conf = {} ;
  agent_conf[:e] = 0.05 ;
  agent_conf[:t] = 0.05 ;
  agent_conf[:arm_num] = 5 ;
  agent_conf[:average_reward] = 0.0 ;
  agent_conf[:id] = 0 ;
  agent_conf[:a] = 0.1 ;

  agent_list = [] ;
  agent1 = BanditAgent.new(agent_conf) ; 
  agent_list.push(agent1) ;
  agent2 = BanditAgent.new(agent_conf) ; 
  agent_list.push(agent2)

  bandit=Bandit.new ;
  # rewards = []  ;
  rewards_list = [] ;

  500.times do |num|
    agent_list.each_with_index do |agent, i|
      rewards_list[i] = [] if rewards_list[i].nil?
      if i == 0
        agent_select = agent.softmax ;
      else
        agent_select = agent.e_greedy ;
      end
      reward = bandit.pull_lever(agent_select) ;
      agent.calc_average_reward(reward,num) ;
      agent.update_q(agent_select,reward) ;
      rewards_list[i].push(agent.average_reward) ;
    end
    # p "#{agent_select}, #{reward}"
  end
  graph_conf = GenerateGraph.make_default_conf
  graph_conf[:graph_title] = [] ;
  graph_conf[:graph_title][0] = "softmax"
  graph_conf[:graph_title][1] = "epsilon"
  # GenerateGraph.time_step(rewards, graph_conf)
  GenerateGraph.list_time_step(rewards_list, graph_conf)
  makeYamlFile("agent.yml", rewards_list)
end


