begin;
create extension if not exists argmax;

create table tbl as 
select d,
	random() || ' ' || d::text t,
	floor(random() * 3)::int grp
from (
	select current_date - generate_series(1, 10000000) d
	order by random()
) _;

savepoint s;

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

create aggregate agg_argmax(date, text) (
	sfunc = fn_argmax_date_text_greater,
	stype = ty_argmax_date_text_state,
	finalfunc = fn_argmax_date_text_extract_payload
);

explain analyze select * from tbl;
--explain analyze select grp, agg_argmax(d, t) from tbl group by grp order by grp;
explain analyze select grp, argmax(d, t) from tbl group by grp order by grp;
--explain analyze select distinct on (grp) grp, t from tbl order by grp, d desc;

--explain select mode() within group (order by d) from tbl group by grp;
--explain select grp, count(distinct d) from tbl group by grp;

rollback;
