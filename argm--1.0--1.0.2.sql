-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION argm UPDATE TO '1.0.2'" to load this file. \quit

drop aggregate if exists argmax(anyelement, variadic "any");
drop aggregate if exists argmin(anyelement, variadic "any");
drop aggregate if exists anyold(anyelement);

create aggregate argmax(anyelement, variadic "any")
(
    sfunc = argmax_transfn,
    stype = internal,
    sspace = 128,
    finalfunc = argm_finalfn,
    finalfunc_extra
);
create aggregate argmin(anyelement, variadic "any")
(
    sfunc = argmin_transfn,
    stype = internal,
    sspace = 128,
    finalfunc = argm_finalfn,
    finalfunc_extra
);
create aggregate anyold(anyelement)
(
    sfunc = anyold_transfn,
    stype = internal,
    sspace = 8,
    finalfunc = anyold_finalfn,
    finalfunc_extra
);
