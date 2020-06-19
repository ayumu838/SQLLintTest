USE hoge;

SELECT
  `on`,
  option,
  onboard,
  col2
FROM
  foo
JOIN bar
  ON foo.col1 = bar.col1
WHERE
  col1 = 'fuga';
