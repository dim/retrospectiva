#!/usr/bin/env ruby

require 'rubygems'
require 'active_support'
require 'action_mailer'

RAILS_ROOT = File.expand_path(File.dirname(__FILE__) + '/..')

class Commit
  
  def self.parse(full_log)
    full_log.split(/^commit /).map do |log|      
      log.blank? ? nil : new("commit #{log}")
    end.compact
  end  

  attr_reader :id, :author, :date, :files

  def initialize(log)
    lines = log.split("\n")
    @message = []
    @files = []
    
    while !lines.empty?
      line = lines.shift
      
      if line.blank?
        # skip
      elsif line =~ /^commit (\w+)$/
        @id = $1
      elsif line =~ /^Author\: ([\w ]+)/
        @author = $1
      elsif line =~ /^Date\: +([\d-]+)/
        @date = Date.strptime($1)
      elsif line =~ /^ {4}(.+)$/ 
        @message << line.strip
      elsif line =~ /^ (.+?) \| /
        @files << $1.strip
      end
    end
  end

  def message(join_with = ' / ')
    @message.join(join_with)
  end
  
  def short_id
    id.first(6)
  end
  
  def file_info
    if files.size > 6
      ["#{files.size} files affected"]
    else
      files
    end.map do |line|
      format "* #{line}", 4
    end.join
  end
  
  def summary
    text = "#{message} [#{short_id}]"
    format(text)
  end
  
  protected
    
    def format(text, indent = 2)
      Text::Format.new( :columns => 72, :first_indent => indent, :body_indent => indent, :text => text ).format      
    end
  
end

full_log = `git log --summary --stat --no-merges --date=short -- #{RAILS_ROOT}`

commit_map = Commit.parse(full_log).inject(ActiveSupport::OrderedHash.new) do |result, commit|
  result[commit.date] ||= ActiveSupport::OrderedHash.new
  result[commit.date][commit.author] ||= []
  result[commit.date][commit.author] << commit
  result
end

commit_map.each do |date, details|
  details.each do |author, commits|
    puts "(#{date}) #{author}"
    
    commits.each do |commit|
      puts "\n" + commit.summary + commit.file_info 
    end
    puts "\n" 
  end
end

