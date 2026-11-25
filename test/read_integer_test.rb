# frozen_string_literal: true

require "minitest/autorun"
require "stringio"
require_relative "../read_integer"

class ReadIntegerTest < Minitest::Test
  def test_returns_parsed_decimal_integers
    cases = [
      "42\n", 42,
      "0\n", 0,
      "-17\n", -17,
      "  99  \n", 99,
      "08\n", 8,
      "010\n", 10
    ]

    cases.each_slice(2) do |raw, expected|
      result = read_integer(input: StringIO.new(raw), output: StringIO.new)
      assert_equal expected, result, "for input #{raw.inspect}"
    end
  end

  def test_returns_nil_on_empty_or_whitespace_input
    ["\n", "   \t  \n"].each do |raw|
      result = read_integer(input: StringIO.new(raw), output: StringIO.new)
      assert_nil result
    end
  end

  def test_returns_nil_on_eof
    result = read_integer(input: StringIO.new(""), output: StringIO.new)
    assert_nil result
  end

  def test_retries_after_invalid_input
    output = StringIO.new
    input = StringIO.new("abc\n3.14\n0x10\n25\n")

    result = read_integer(input: input, output: output)

    assert_equal 25, result
    assert_includes output.string, "Geçersiz tamsayı: 'abc'."
    assert_includes output.string, "Geçersiz tamsayı: '3.14'."
    assert_includes output.string, "Geçersiz tamsayı: '0x10'."
  end

  def test_enforces_range_bounds
    output = StringIO.new
    input = StringIO.new("0\n101\n50\n")

    result = read_integer(range: 1..100, input: input, output: output)

    assert_equal 50, result
    assert_includes output.string, "Aralık dışında (1..100): 0."
    assert_includes output.string, "Aralık dışında (1..100): 101."
  end

  def test_supports_open_and_exclusive_ranges
    assert_equal 0, read_integer(range: 0.., input: StringIO.new("-1\n0\n"), output: StringIO.new)
    assert_equal 9, read_integer(range: 1...10, input: StringIO.new("10\n9\n"), output: StringIO.new)
    assert_equal 5, read_integer(range: ..10, input: StringIO.new("11\n5\n"), output: StringIO.new)
  end

  def test_supports_custom_base
    result = read_integer(base: 16, input: StringIO.new("ff\n"), output: StringIO.new)
    assert_equal 255, result
  end

  def test_prints_custom_prompt
    output = StringIO.new
    result = read_integer("Yaşınız: ", input: StringIO.new("21\n"), output: output)

    assert_equal 21, result
    assert_equal "Yaşınız: ", output.string
  end
end
