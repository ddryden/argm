/* 
 * PERFORMANCE TESTS
 */

begin;

/* C implementation */
drop extension if exists argm;
create extension if not exists argm;

/* plpgsql implementation */
create type ty_argmax_date_text_state as (
	d_date date,
	t_payload text
);

create function fn_argmax_date_text_greater(p_ty_state ty_argmax_date_text_state, p_t_payload text, p_d_date date)
returns ty_argmax_date_text_state as $$
	select case when p_d_date <= p_ty_state.d_date
	            then p_ty_state
	            else (p_d_date, p_t_payload)::ty_argmax_date_text_state
	       end;
$$ language sql;

create function fn_argmax_date_text_extract_payload(p_ty_state ty_argmax_date_text_state)
returns text as $$
	select p_ty_state.t_payload;
$$ language sql;

create aggregate plpgsql_argmax(text, date) (
	sfunc = fn_argmax_date_text_greater,
	stype = ty_argmax_date_text_state,
	finalfunc = fn_argmax_date_text_extract_payload
);

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
explain analyze select grp, plpgsql_argmax(t, d) from tbl group by grp order by grp;
explain analyze select grp, argmax(t, d) from tbl group by grp order by grp;

/* TODO: write tests for anyold */

rollback;


/*
 * FUNCTIONAL TESTS
 */

begin;

drop extension if exists argm;
create extension if not exists argm;

create table tbl as 
select d,
	array[random() || ' ' || d::text] t,
	floor(random() * 3)::int grp
from (
	select current_date - generate_series(1, 10) d
	order by random()
) _;

analyze tbl;

\df argmax
\da argmax
select grp, argmax(d, t) from tbl group by grp order by grp;

/* TODO: write tests for anyold */
/* TODO: write tests for multi-column argmax */
/* TODO: write tests for argmin */
/* TODO: write tests for different datatatypes */

rollback;

