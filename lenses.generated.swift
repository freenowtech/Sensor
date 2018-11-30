// Generated using Sourcery 0.10.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable variable_name
infix operator *~: MultiplicationPrecedence
infix operator |>: AdditionPrecedence

struct Lens<Whole, Part> {
    let get: (Whole) -> Part
    let set: (Part, Whole) -> Whole
}

func * <A, B, C> (lhs: Lens<A, B>, rhs: Lens<B, C>) -> Lens<A, C> {
    return Lens<A, C>(
        get: { a in rhs.get(lhs.get(a)) },
        set: { (c, a) in lhs.set(rhs.set(c, lhs.get(a)), a) }
    )
}

func *~ <A, B> (lhs: Lens<A, B>, rhs: B) -> (A) -> A {
    return { a in lhs.set(rhs, a) }
}

func |> <A, B> (x: A, f: (A) -> B) -> B {
    return f(x)
}

func |> <A, B, C> (f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { g(f($0)) }
}

extension LoginViewModel.StateModel {
  static let sideeffectLens = Lens<LoginViewModel.StateModel, Signal<Action>?> (
    get: { $0.sideeffect },
    set: { sideeffect, statemodel in
       LoginViewModel.StateModel(sideeffect: sideeffect, username: statemodel.username, password: statemodel.password, state: statemodel.state, user: statemodel.user, isPasswordHidden: statemodel.isPasswordHidden, isLoginButtonEnabled: statemodel.isLoginButtonEnabled)
    }
  )
  static let usernameLens = Lens<LoginViewModel.StateModel, String> (
    get: { $0.username },
    set: { username, statemodel in
       LoginViewModel.StateModel(sideeffect: statemodel.sideeffect, username: username, password: statemodel.password, state: statemodel.state, user: statemodel.user, isPasswordHidden: statemodel.isPasswordHidden, isLoginButtonEnabled: statemodel.isLoginButtonEnabled)
    }
  )
  static let passwordLens = Lens<LoginViewModel.StateModel, String> (
    get: { $0.password },
    set: { password, statemodel in
       LoginViewModel.StateModel(sideeffect: statemodel.sideeffect, username: statemodel.username, password: password, state: statemodel.state, user: statemodel.user, isPasswordHidden: statemodel.isPasswordHidden, isLoginButtonEnabled: statemodel.isLoginButtonEnabled)
    }
  )
  static let stateLens = Lens<LoginViewModel.StateModel, LoginViewModel.StateModel.State> (
    get: { $0.state },
    set: { state, statemodel in
       LoginViewModel.StateModel(sideeffect: statemodel.sideeffect, username: statemodel.username, password: statemodel.password, state: state, user: statemodel.user, isPasswordHidden: statemodel.isPasswordHidden, isLoginButtonEnabled: statemodel.isLoginButtonEnabled)
    }
  )
  static let userLens = Lens<LoginViewModel.StateModel, User> (
    get: { $0.user },
    set: { user, statemodel in
       LoginViewModel.StateModel(sideeffect: statemodel.sideeffect, username: statemodel.username, password: statemodel.password, state: statemodel.state, user: user, isPasswordHidden: statemodel.isPasswordHidden, isLoginButtonEnabled: statemodel.isLoginButtonEnabled)
    }
  )
  static let isPasswordHiddenLens = Lens<LoginViewModel.StateModel, Bool> (
    get: { $0.isPasswordHidden },
    set: { isPasswordHidden, statemodel in
       LoginViewModel.StateModel(sideeffect: statemodel.sideeffect, username: statemodel.username, password: statemodel.password, state: statemodel.state, user: statemodel.user, isPasswordHidden: isPasswordHidden, isLoginButtonEnabled: statemodel.isLoginButtonEnabled)
    }
  )
  static let isLoginButtonEnabledLens = Lens<LoginViewModel.StateModel, Bool> (
    get: { $0.isLoginButtonEnabled },
    set: { isLoginButtonEnabled, statemodel in
       LoginViewModel.StateModel(sideeffect: statemodel.sideeffect, username: statemodel.username, password: statemodel.password, state: statemodel.state, user: statemodel.user, isPasswordHidden: statemodel.isPasswordHidden, isLoginButtonEnabled: isLoginButtonEnabled)
    }
  )
}
