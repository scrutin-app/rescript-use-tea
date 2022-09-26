type subAction<'action,'effect> =
  | DomainAction('action)
  | RemoveEffects

let useTea = (reducer : (('state, 'action) => ('state, 'effect)), initialState: 'state) => {

  let teaReducer = ((state, effects), action) => {
    switch action {
      | RemoveEffects => ( state, [] )
      | DomainAction(action) => {
        let (nextState, nextEffects) = reducer(state, action)
        ( nextState, effects->Belt.Array.concat(nextEffects) )
      }
    }
  }

  let ((state, effects), dispatch) = React.useReducer(teaReducer, (initialState, []))

  let subDispatch = (action) => dispatch(DomainAction(action))

  React.useEffect1(() => {
    effects -> Belt.Array.forEach(fx => fx((action) => dispatch(DomainAction(action))))
    dispatch(RemoveEffects)
    None
  }, [effects]);

  (state, subDispatch)
}
