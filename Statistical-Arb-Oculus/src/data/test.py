def half_life(spread):
    
    spread_lag = spread.shift(1)
    spread_lag.ix[0] = spread_lag.ix[1]

    s_ret = spread - spread_lag
    s_ret.ix[0] = s_ret.ix[1]

    spread_lag2 = sm.add_constant(spread_lag)

    model = sm.OLS(s_ret,s_lag2)
    res = model.fit()

    halflife = round(-np.log(2) / res.params[1],0)
    
    return halflife