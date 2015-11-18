/*
 * TODO: write smth here
 */

#include "postgres.h"
#include "fmgr.h"
#include "utils/date.h"
#include "utils/memutils.h"

PG_MODULE_MAGIC;

typedef struct ArgmaxDateState {
	MemoryContext context;
	bool          date_is_null;
	DateADT       date;
	Oid           payload_type;
	bool          payload_is_null;
	Datum         payload;
} ArgmaxDateState;

Datum
argmax_date_transfn(PG_FUNCTION_ARGS);

Datum
argmax_finalfn(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(argmax_date_transfn);
Datum
argmax_date_transfn(PG_FUNCTION_ARGS)
{
	Oid              payload_type;
	ArgmaxDateState *state;
	bool             date_is_null;
	DateADT          date;
	MemoryContext    aggcontext, oldcontext, localcontext;
	
	if (!AggCheckCallContext(fcinfo, &aggcontext))
	{
		/* cannot be called directly because of internal-type argument */
		elog(ERROR, "array_agg_transfn called in non-aggregate context");
	}

	state = PG_ARGISNULL(0) ? NULL : (ArgmaxDateState *) PG_GETARG_POINTER(0);

	payload_type = get_fn_expr_argtype(fcinfo->flinfo, 2);
	if (payload_type == InvalidOid)
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
				 errmsg("could not determine input data type")));
	
	if (state == NULL)
	{
		/* First time through --- initialize */
		
		/* Make a temporary context to hold all the junk */
		localcontext = AllocSetContextCreate(aggcontext,
											 "argmax_date_transfn",
											 ALLOCSET_DEFAULT_MINSIZE,
											 ALLOCSET_DEFAULT_INITSIZE,
											 ALLOCSET_DEFAULT_MAXSIZE);
		oldcontext = MemoryContextSwitchTo(localcontext);
		
		state = palloc(sizeof(ArgmaxDateState));
		
		state->context = localcontext;
		
		state->payload_type = payload_type;
		
		state->date_is_null = PG_ARGISNULL(1);
		if (!state->date_is_null)
/**/			state->date = PG_GETARG_DATEADT(1);
		
		state->payload_is_null = PG_ARGISNULL(2);
		if (!state->payload_is_null)
			state->payload = PointerGetDatum(PG_DETOAST_DATUM_COPY(PG_GETARG_DATUM(2)));
	}
	else
	{
		oldcontext = MemoryContextSwitchTo(state->context);
		Assert(state->payload_type == payload_type);
		
		date_is_null = PG_ARGISNULL(1);
/**/		date = PG_GETARG_DATEADT(1);
/**/		if (!date_is_null && (state->date_is_null || state->date < date))
		{
			state->date_is_null = date_is_null;
/**/			state->date = date;
			pfree(DatumGetPointer(state->payload));
			state->payload = PointerGetDatum(PG_DETOAST_DATUM_COPY(PG_GETARG_DATUM(2)));
		}
	}
	
	MemoryContextSwitchTo(oldcontext);
	
	PG_RETURN_POINTER(state);
}

PG_FUNCTION_INFO_V1(argmax_finalfn);
Datum
argmax_finalfn(PG_FUNCTION_ARGS)
{
	ArgmaxDateState *state;

	/* cannot be called directly because of internal-type argument */
	Assert(AggCheckCallContext(fcinfo, NULL));

	state = (ArgmaxDateState *) PG_GETARG_POINTER(0);
	
	if (state->payload_is_null)
		PG_RETURN_NULL();
	
	PG_RETURN_DATUM(state->payload);
}
