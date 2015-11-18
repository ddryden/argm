-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION argmax" to load this file. \quit

create function argmax_date_transfn(internal, date, anynonarray) returns internal as
	'MODULE_PATHNAME', 'argmax_date_transfn' language c;
create function argmax_finalfn(internal, date, anynonarray) returns anynonarray as
	'MODULE_PATHNAME', 'argmax_finalfn' language c;

create aggregate argmax(date, anynonarray)
(
    sfunc = argmax_date_transfn,
    stype = internal,
    finalfunc = argmax_finalfn,
    finalfunc_extra
);
