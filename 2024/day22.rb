# frozen_string_literal: true

def simulate(n)
  n ^= n << 6
  n %= 16_777_216
  n ^= n >> 5
  n %= 16_777_216
  n ^= n << 11
  n %= 16_777_216
  n
end

p1 = 0
sequences_prices = Hash.new(0)
ARGF.each do |line|
  next if line.strip.empty?

  sn = line.to_i
  prices = [sn % 10]
  2000.times do
    sn = simulate(sn)
    prices << sn % 10
  end
  price_dif = prices.each_cons(2).map { |a, b| b - a }
  seen_seq = Set.new
  price_dif.each_cons(4).with_index do |seq, i|
    unless seen_seq.include?(seq)
      seen_seq << seq
      sequences_prices[seq] += prices[i + 4]
    end
  end
  p1 += sn
end

puts "Part1: #{p1}"
puts "Part1: #{sequences_prices.values.max}"
