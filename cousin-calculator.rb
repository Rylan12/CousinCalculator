#!/usr/bin/env ruby

require "ordinalize_full/integer"

ME = "1.2.1.2.8.1.2.1"

raise ArgumentError, "Must specify a target" if ARGV[0].nil?

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

puts <<~EOS
  Calculating relationship:
    Base:   #{base.join(".")}
    Target: #{target.join(".")}
EOS

common_ancestry_index = find_common_ancestry_position base, target

if common_ancestry_index.nil?
  puts "No common ancestry."
  exit
end

common_ancestry = base[0..common_ancestry_index]

base.shift common_ancestry.length
target.shift common_ancestry.length

puts <<~EOS
  Common ancestry found: #{common_ancestry.join(".")}
  Differing ancestry:
    Base:   .#{base.join(".")}
    Target: .#{target.join(".")}
EOS

base_grandparent = base.length - 2
target_grandparent = target.length - 2

if base_grandparent.negative? || target_grandparent.negative?
  # TODO: Implement sibling/parent/neice/nephew relationship
  puts "Unable to calculate relationship."
  exit 1
end

puts <<~EOS
  Grandparent Numbers:
    Base:   #{base_grandparent}
    Target: #{target_grandparent}
EOS

cousin_number = if target_grandparent <= base_grandparent
  target_grandparent + 1
else
  base_grandparent + 1
end
removal_number = (target_grandparent - base_grandparent).abs

puts <<~EOS
  Relationship:
    Cousin:  #{cousin_number}
    Removal: #{removal_number}
EOS

removal_phrase = if removal_number.zero?
  ""
else
  number_of_times = if removal_number == 1
    "once"
  elsif removal_number == 2
    "twice"
  else
    "#{removal_number} times"
  end

  ", #{number_of_times} removed"
end

relationship = "#{cousin_number.ordinalize} cousin#{removal_phrase}."

puts "Relationship: #{relationship}"
