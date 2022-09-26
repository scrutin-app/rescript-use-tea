type teaState<'state, 'effect> = { state: 'state, effects: array<'effect> }

type subAction<'action,'effect> =
  | DomainAction('action)
  | RemoveEffects

let useTea = (reducer, initialState) => {

  let teaReducer = ({state, effects}, action) => {
    switch action {
      | RemoveEffects => { state, effects: [] }
      | DomainAction(action) => {
        let result = reducer(state, action)
        { state: result.state, effects: effects->Belt.Array.concat(result.effects) }
      }
    }
  }

  let ({state, effects}, dispatch) = React.useReducer(teaReducer, initialState)

  let subDispatch = (action) => dispatch(DomainAction(action))

  React.useEffect1(() => {
    effects -> Belt.Array.forEach(fx => fx((action) => dispatch(DomainAction(action))))
    dispatch(RemoveEffects)
    None
  }, [effects]);

  [state, subDispatch]
}
