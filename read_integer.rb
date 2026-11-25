#!/usr/bin/env ruby
# frozen_string_literal: true

DEFAULT_PROMPT = "Lütfen bir tamsayı girin [ENTER sonlandırır]: "

def read_integer(
  prompt = DEFAULT_PROMPT,
  range: nil,
  base: 10,
  input: $stdin,
  output: $stdout
)
  message = prompt

  loop do
    output.print(message)
    output.flush

    line = input.gets
    return nil if line.nil?

    text = line.strip
    return nil if text.empty?

    number = Integer(text, base, exception: false)
    if number.nil?
      message = "Geçersiz tamsayı: '#{text}'. Lütfen tekrar girin: "
      next
    end

    if range && !range.cover?(number)
      message = "Aralık dışında (#{range}): #{number}. Lütfen tekrar girin: "
      next
    end

    return number
  end
end

if __FILE__ == $PROGRAM_NAME
  begin
    number = read_integer
    if number
      puts "Girilen tamsayı: #{number}"
    else
      puts "Giriş iptal edildi."
    end
  rescue Interrupt
    puts "\nGiriş iptal edildi."
    exit 130
  end
end
