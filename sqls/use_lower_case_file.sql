USE hoge;

Select
  col1,
  col2
from
  foo
JoIN bar
  on foo.col1 = bar.col1
wHERE
  col1 = 'fuga';
