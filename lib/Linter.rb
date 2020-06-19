# frozen_string_literal: true

class Linter
  RESERVED_WORDS = %w[SELECT FROM WHERE JOIN ON AND OR IS NULL NOT USE].freeze

  def initialize(file_name)
    @file = File.new(file_name)
  end

  def exec_lint
    lints = []
    before = { spaces: 0 }
    @file.each_line do |line|
      lint, before = lint(line, before)
      lints.push(lint) unless lint.empty?
    end
    @lints = lints.flatten
  end

  private

  def lint(line, before)
    results = []
    line_number = $.

    # USEがあるかチェック
    results.push(check_use_in_first_line(line, line_number))

    # 予約後は大文字化をチェック
    results.push(check_reserved_word(line, line_number))

    # タブがあるかのチェック
    results.push(check_tabs(line, line_number))

    # インデントのチェック
    results.push(check_indent(line, line_number, before[:spaces]))

    # 空行が複数行に渡ってあるかチェック
    results.push(check_duplicate_line(line, line_number, before[:line]))

    before[:line] = line
    before[:spaces] = space_count(line)

    [results.compact, before]
  end

  def space_count(str)
    str.rstrip.length - str.strip.length
  end

  def check_use_in_first_line(line, line_number)
    "#{line_number}行目にUSEがありません" if line_number == 1 && /USE/i !~ line
  end

  def check_reserved_word(line, line_number)
    results = []
    RESERVED_WORDS.each do |reserved_word|
      next unless /.*[?!^\s](#{reserved_word})\s/i =~ line

      match_word = $&.strip

      next line if /`#{reserved_word}`/i =~ line

      results.push "#{line_number}行目の#{$&}は大文字にする必要があります #{$&} -> #{reserved_word}" if match_word != reserved_word
    end
    results
  end

  def check_tabs(line, line_number)
    "#{line_number}行目にタブが存在します" if line.include?("\t")
  end

  def check_indent(line, line_number, before_space)
    count = space_count(line)
    return if count == before_space || count == before_space - 2 || count == before_space + 2

    "#{line_number}行目のインデントを直してください"
  end

  def check_duplicate_line(line, line_number, before_line)
    "#{line_number}行目の空行は不要です" if before_line == "\n" && line == "\n"
  end
end
