# frozen_string_literal: true

SQLS_PATH = 'sqls'
RESERVED_WORDS = %w[SELECT FROM WHERE JOIN ON AND OR IS NULL NOT USE].freeze

def main
  results = {}
  sql_file_names.each do |file_name|
    result = file(file_name)
    results[file_name] = result unless result.empty?
  end
  results
end

def sql_file_names
  Dir.glob("#{SQLS_PATH}/*.sql")
end

def file(file_name)
  file = File.new(file_name)

  before = {spaces: 0}
  lints = []
  file.each_line do |line|
    lint, before = lint(line, before)
    lints.push(lint) unless lint.empty?
  end

  lints.flatten
end

def lint(line, before)
  results = []
  line_number = $INPUT_LINE_NUMBER

  # USEがあるかチェック
  results.push(check_use_in_first_line(line, line_number))

  # 予約後は大文字化をチェック
  results.push(check_reserved_word(line, line_number))

  # タブがあるかのチェック
  results.push(check_tabs(line, line_number))

  # インデントのチェック
  results.push(check_indent(line, line_number, before[:spaces]))

  before[:line] = line
  before[:spaces] = space_count(line)

  [results.compact, before]
end

def check_use_in_first_line(line,line_number)
  "#{line_number}行目にUSEがありません" if line_number == 1 && /USE/i !~ line
end

def check_reserved_word(line, line_number)
  results = []
  RESERVED_WORDS.each do |reserved_word|
    if /#{reserved_word}/i =~ line
      results.push "#{line_number}行目の#{$&}は大文字にする必要があります #{$&} -> #{reserved_word}" if $& != reserved_word
    end
  end
  results
end

def check_tabs(line, line_number)
  "#{line_number}行目にタブが存在します" if line.include?("\t")
end

def check_indent(line, line_number, before_space)
  count = space_count(line)
  "#{line_number}行目のインデントを直してください #{line}, #{count}" unless count == before_space || count == before_space - 2 || count == before_space + 2
end

def space_count(str)
  str.length - str.lstrip.length
end

results = main

results.each do |k, vs|
  p k
  vs.each do |v|
    p "  | #{v}"
  end
end

exit(results.empty?)