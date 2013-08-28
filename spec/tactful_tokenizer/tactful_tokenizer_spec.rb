# -*- encoding : utf-8 -*-
require 'spec_helper'

describe String do
  describe "::is_upper_case?" do
    it "should be false" do
      "asdfghjk".is_upper_case?.should == false
    end

    it "should be true" do
      "ASDFGHJK".is_upper_case?.should == true
    end
  end

  describe "::is_alphabetic?" do
    it "should be false" do
      "!^?".is_alphabetic?.should == false
    end

    it "should be true" do
      "some text".is_alphabetic?.should == true
    end

    it "should be true for unicode text" do
      "русский текст öö üüü".is_alphabetic?.should == true
    end    
  end
end

describe TactfulTokenizer::Doc do
  describe "::segment" do
    it "should return array of segments" do
      model = TactfulTokenizer::Model.new
      doc = TactfulTokenizer::Doc.new("Hello!\nMy name is Richard Stewart.\nHow are you?\n")
      model.featurize doc
      model.classify doc
      doc.segment.should == ["Hello!", "My name is Richard Stewart.", "How are you?"]
    end
  end
end

describe TactfulTokenizer::Frag do
  describe "::clean" do
    before :each do
      @frag = TactfulTokenizer::Frag.new
      @cleaned = @frag.clean("1 good bad 23 ?!")
    end

    it "should return an instance of Array" do
      @cleaned.class.should == Array
    end

    it "should normalize numbers and discard ambiguous punctuation" do
      @cleaned.should == ["<NUM>", "good", "bad", "<NUM>", "?", "!"]
    end
  end
end

describe TactfulTokenizer::Model do
  before :each do
    @m = TactfulTokenizer::Model.new
    File.open('spec/files/sample.txt') do |f|
      @text = f.read
    end
  end

  describe "::classify" do
    it "should assign a prediction for frags" do
      doc = TactfulTokenizer::Doc.new("Hello!\n")
      @m.featurize(doc)
      @m.classify(doc).first.pred.should > 0.5
    end
  end

  describe "::featurize" do
    it "should get the features of every fragment" do
      doc = TactfulTokenizer::Doc.new("Hello!\n")
      @m.featurize(doc).first.features.should == ["w1_!", "w2_", "both_!_"]
    end
  end

  describe "::tokenize_text" do
    it "should tokenize correctly" do
      text = @m.tokenize_text(@text)
      File.open("spec/files/test_out.txt", "w+") do |g|
        text.each do |line|
          g.puts line unless line.empty?
        end   
        g.rewind 
        t2 = g.read
        t1 = File.open("spec/files/verification_out.txt").read
        t1.should == t2
      end
    end
  end
end