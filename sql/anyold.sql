/*
 * FUNCTIONAL TESTS
 */
create extension if not exists argm;

create table tbl2 as 
select d,
	i,
	grp::text || repeat('1', 10) txt,
	grp
from (
	select date'2011-11-11' - generate_series(1, 8) d,
		generate_series(1, 9) i
	order by random()
) _
cross join (values
	(1),
	(2),
	(3)
) grp (grp);

analyze tbl2;

select grp, anyold(txt), sum(i) from tbl2 group by grp order by grp;

