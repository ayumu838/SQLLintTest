# frozen_string_literal: true

require './lib/Linter'

SQLS_PATH = 'sqls'

results = {}
sql_file_names = Dir.glob("#{SQLS_PATH}/*.sql")

sql_file_names.each do |file_name|
  linter = Linter.new(file_name)
  result = linter.exec_lint
  results[file_name] = result unless result.empty?
end



results.each do |k, vs|
  p k
  vs.each do |v|
    p "  | #{v}"
  end
end

exit(results.empty?)
