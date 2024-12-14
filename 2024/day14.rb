# frozen_string_literal: true

# WIDTH = 11
# HEIGHT = 7
WIDTH = 101
HEIGHT = 103

def parse_robots
  result = []
  $stdin.each do |line|
    numbers = line.strip.scan(/[-+]?\d+/).map(&:to_i)
    next if numbers.empty?

    pos = Complex(numbers[0], numbers[1])
    vel = Complex(numbers[2], numbers[3])
    result << [pos, vel]
  end
  result
end

def position_at_time(pos, vel, time)
  final_position = pos + vel * time
  # wrap
  Complex(final_position.real % WIDTH, final_position.imag % HEIGHT)
end

def count_in_quadrant(positions)
  result = [0, 0, 0, 0]
  half_width = WIDTH / 2
  half_height = HEIGHT / 2
  positions.each do |pos_complex|
    x = pos_complex.real
    y = pos_complex.imag
    if x < half_width && y < half_height
      result[0] += 1
    elsif x > half_width && y < half_height
      result[1] += 1
    elsif x < half_width && y > half_height
      result[2] += 1
    elsif x > half_width && y > half_height
      result[3] += 1
    end
  end
  result
end

def variance(nobs, lin_sum, quad_sum)
  nobs = nobs.to_f
  lin_sum = lin_sum.to_f
  quad_sum = quad_sum.to_f
  mean = lin_sum / nobs
  quad_sum / nobs - mean * mean
end

def pos_variability(positions, stop_early)
  n = sx = sx2 = sy = sy2 = 0
  positions.each do |pos_complex|
    x = pos_complex.real
    y = pos_complex.imag
    n += 1
    sx += x
    sy += y
    sx2 += x * x
    sy2 += y * y
    if n > 200
      cur_variance = variance(n, sx, sx2) + variance(n, sy, sy2)
      return nil if cur_variance > stop_early
    end
  end
  variance(n, sx, sx2) + variance(n, sy, sy2)
end

def group_robots(positions)
  count = Hash.new(0)
  positions.each { |p| count[p] += 1 }
  count
end

def display(positions)
  counts = group_robots(positions)
  (0..HEIGHT).each do |y|
    (0..WIDTH).each do |x|
      key = Complex(x, y)
      if counts.key?(key)
        print counts[key]
      else
        print '.'
      end
    end
    puts
  end
end

robots = parse_robots

time = 100
robots_final_pos = robots.map { |pos, vel| position_at_time(pos, vel, time) }
quadrant_count = count_in_quadrant(robots_final_pos)

p1 = quadrant_count.reduce(1, &:*)
puts "Part1: #{p1}"

# Manual labor for part 2!!!
max_time = 10_000
min_variance = Float::INFINITY
(0..max_time).each do |t|
  robots_pos = robots.map { |pos, vel| position_at_time(pos, vel, t) }
  position_variance = pos_variability(robots_pos, min_variance)
  next if position_variance.nil?

  min_variance = position_variance < min_variance ? position_variance : min_variance
  puts "Time #{t}\t#{position_variance}"
  display(robots_pos)
end
