begin;

/* sql implementation of argmax*/
\ir _argmax-sql.sql

/* C implementation of argmax*/
create extension argm;

/* prepare data */
create table tbl as 
select d,
	random() || ' ' || d::text t,
	floor(random() * 3)::int grp
from (
	select current_date - generate_series(1, 1000000/*0*/) d
	order by random()
) _;
analyze tbl;

/* show scan performance */
explain analyze select * from tbl;

/* compare 3 different methods of the same computation */
explain analyze select distinct on (grp) grp, t from tbl order by grp, d desc;
explain analyze select grp, sql_argmax(t, d) from tbl group by grp order by grp;
explain analyze select grp, argmax(t, d) from tbl group by grp order by grp;

rollback;
