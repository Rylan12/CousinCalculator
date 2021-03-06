#!/usr/bin/env ruby
# frozen_string_literal: true

require "colorize"
require "ordinalize_full/integer"

ME = "1.2.1.2.8.1.2.1"

raise ArgumentError, "Must specify a target" if ARGV[0].nil?

@verbose = false

def output(*message)
  puts(*message) if @verbose
end

def find_common_ancestry_position(base, target)
  min_length = [base.length, target.length].min
  latest_common_index = nil

  base.length.times do |index|
    break if index >= min_length
    break if base[index] != target[index]

    latest_common_index = index
  end

  latest_common_index
end

base = ME.split "."
target = ARGV[0].split "."

output <<~OUTPUT
  Calculating relationship:
    Base:   #{base.join(".")}
    Target: #{target.join(".")}
OUTPUT

common_ancestry_index = find_common_ancestry_position base, target

if common_ancestry_index.nil?
  puts "No common ancestry."
  exit
end

common_ancestry = base[0..common_ancestry_index]

base.shift common_ancestry.length
target.shift common_ancestry.length

output <<~OUTPUT
  Common ancestry found: #{common_ancestry.join(".")}
  Differing ancestry:
    Base:   .#{base.join(".")}
    Target: .#{target.join(".")}
OUTPUT

base_grandparent = base.length - 2
target_grandparent = target.length - 2

output <<~OUTPUT
  Grandparent Numbers:
    Base:   #{base_grandparent}
    Target: #{target_grandparent}
OUTPUT

def child_relationship(generation_gap)
  output "Child generation gap: #{generation_gap}"

  case generation_gap
  when 1 then "Child"
  when 2 then "Grandchild"
  when 3 then "Great grandchild"
  else
    num_greats = generation_gap - 2
    "#{num_greats.ordinalize} great grandchild"
  end
end

def nibling_relationship(generation_gap)
  output "Nibling generation gap: #{generation_gap}"

  case generation_gap
  when 1 then "Nibling"
  when 2 then "Grand nibling"
  when 3 then "Great grand nibling"
  else
    num_greats = generation_gap - 2
    "#{num_greats.ordinalize} great grand nibling"
  end
end

def cousin_relationship(base_grandparent, target_grandparent)
  cousin_number = if target_grandparent <= base_grandparent
    target_grandparent + 1
  else
    base_grandparent + 1
  end
  removal_number = (target_grandparent - base_grandparent).abs

  output <<~OUTPUT
    Relationship:
      Cousin:  #{cousin_number}
      Removal: #{removal_number}
  OUTPUT

  "#{cousin_number.ordinalize} cousin#{cousin_removal_phrase(removal_number)}"
end

def cousin_removal_phrase(removal_number)
  return "" if removal_number.zero?

  number_of_times = case removal_number
  when 1 then "once"
  when 2 then "twice"
  else "#{removal_number} times"
  end

  ", #{number_of_times} removed"
end

relationship = if base_grandparent == -2 && target_grandparent == -2
  "Same person"
elsif base_grandparent == -1 && target_grandparent == -1
  "Sibling"
elsif base_grandparent == -2 || target_grandparent == -2
  child_relationship [base_grandparent, target_grandparent].max + 2
elsif base_grandparent == -1 || target_grandparent == -1
  nibling_relationship [base_grandparent, target_grandparent].max + 1
else
  cousin_relationship base_grandparent, target_grandparent
end

if @verbose
  puts "Relationship: #{relationship.bold}."
else
  puts relationship
end
