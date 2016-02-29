begin;

/* C implementation */
drop extension if exists pg_argmax;
create extension if not exists pg_argmax;

/* plpgsql implementation */
create type ty_argmax_date_text_state as (
	d_date date,
	t_payload text
);

create function fn_argmax_date_text_greater(p_ty_state ty_argmax_date_text_state, p_d_date date, p_t_payload text)
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

create aggregate plpgsql_argmax(date, text) (
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
	select current_date - generate_series(1, 100000/*00*/) d
	order by random()
) _;
analyze tbl;

/* show scan performance */
explain analyze select * from tbl;

/* compare 3 different methods of the same computation */
explain analyze select distinct on (grp) grp, t from tbl order by grp, d desc;
explain analyze select grp, plpgsql_argmax(d, t) from tbl group by grp order by grp;
explain analyze select grp, argmax(d, t) from tbl group by grp order by grp;

rollback;

---

begin;

drop extension if exists argmax;
create extension if not exists argmax;

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

rollback;
