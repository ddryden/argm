# Argm
This PostgreSQL extension proivide several aggregate functions
that could be used for SQL queries simplification and speedup.

## Argmax and argmin
```
argmax(value, key_1, key_2, ...)
argmin(value, key_1, key_2, ...)
```

These functions pick the row with the highest/lowest keys combination
within each group and return the corresponding values. Keys tuples are compared
lexicographically, just like rows. Nulls are handled as unknown values. 
See [PostgreSQL docs](http://www.postgresql.org/docs/current/static/functions-comparisons.html#ROW-WISE-COMPARISON)
for more info on row-wise comparison.
If there are several lines with the same keys the result line and value will be 
chosen arbitrarily.

Values could be of any PostgreSQL data type, while keys must be sortable.
Return type is the same as value parameter type.

Logically using these functions with GROUP BY clause
```
SELECT argmax(value, key_1, key_2)
FROM some_table                   
GROUP BY gr                       
```
is equivalent to DISTINCT ON clause
```
SELECT DISTINCT ON (gr) value       
FROM some_table                     
ORDER BY gr,
         key_1 DESC,
         key_2 DESC 
```
but there are the following pros and cons:

* `GROUP BY` can use any grouping algorithm, including HashAgg.
  While `DISTINCT ON` needs the input to be sorted. 
  This means in general `argmax`/`argmin` is faster.
* `argmax`/`argmin` can be used along with other aggregate functions using the same 
  grouping clause. With `DISTINCT ON` one can select only values 
  calculated on the row chosen.
* `argmax`/`argmin` can only order ascending or descending by all columns, use only 
  one collation, nulls are always chosen last. `DISTINCT ON` can order
  using different directions, collations and nulls policies for different keys.

## Anyold

```anyold(value) ```

This function simply returns the first non-null value within the group. 
Any PostgreSQL types are supported.
The function can be useful to write a value in a select list without grouping by
it and without calling any essential aggregate function. That is, the following 
queries are equivalent if `foo_details` is determined by `foo`:

### Grouping by both columns
```
SELECT foo,
       foo_details,
       sum(bar)
FROM some_table
GROUP BY foo,
         foo_details
```
This approach often leads to cardinality misestimations resulting in suboptimal 
execution plans. Additionally there is an overhead in hashing/sorting 
`foo_details` values while grouping by them.
### Using `min` function
```
SELECT foo,
       min(foo_details),
       sum(bar)
FROM some_table
GROUP BY foo
```
This requires a proper `min` function for the data type of foo_details. Also
calculating a minimum of the values is still an overhead despite all the values 
are equal.
### Using `anyold`
```
SELECT foo,
       anyold(foo_details),
       sum(bar)
FROM some_table
GROUP BY foo
```
`anyold` function is faster than `min`

# Installation

To install the extension for your database cluster run the following command:
```
make && sudo make install && make installcheck
```
This requires `pg_config` from your PostgreSQL installation to be available
in `$PATH`

To use the extension on particular database run the following SQL:
```
CREATE EXTENSION argm;
```

