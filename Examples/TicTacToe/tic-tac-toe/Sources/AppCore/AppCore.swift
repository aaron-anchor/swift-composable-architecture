import AuthenticationClient
import ComposableArchitecture
import Dispatch
import LoginCore
import NewGameCore
import TrackingClient

public enum AppState: Equatable {
  case login(LoginState)
  case newGame(NewGameState)

  public init() { self = .login(LoginState()) }
}

public enum AppAction: Equatable {
  case login(LoginAction)
  case newGame(NewGameAction)
}

public struct AppEnvironment {
  public var authenticationClient: AuthenticationClient
  public var trackingClient: TrackingClient

  public init(
    authenticationClient: AuthenticationClient,
    trackingClient: TrackingClient
  ) {
    self.authenticationClient = authenticationClient
    self.trackingClient = trackingClient
  }
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  loginReducer.pullback(
    state: /AppState.login,
    action: /AppAction.login,
    environment: {
      LoginEnvironment(
        authenticationClient: $0.authenticationClient
      )
    }
  ),
  newGameReducer.pullback(
    state: /AppState.newGame,
    action: /AppAction.newGame,
    environment: { _ in NewGameEnvironment() }
  ),
  Reducer { state, action, _ in
    switch action {
    case let .login(.twoFactor(.twoFactorResponse(.success(response)))),
      let .login(.loginResponse(.success(response))) where !response.twoFactorRequired:
      state = .newGame(NewGameState())
      return .none

    case .login:
      return .none

    case .newGame(.logoutButtonTapped):
      state = .login(LoginState())
      return .none

    case .newGame:
      return .none
    }
  },
  trackingReducer
)

let trackingReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {

    case let .newGame(.game(.cellTapped(row, col))):

        if case let .newGame(newGameState) = state,
            let gameState = newGameState.game {
            environment.trackingClient.track(
                "Player Tapped Cell", [
                    "current_player_name": gameState.currentPlayerName,
                    "cell_row_col": "(\(row), \(col))"
                ]
            )
        }

        if case let .newGame(newGameState) = state,
           let gameState = newGameState.game, gameState.board.hasWinner {
            environment.trackingClient.track(
                "Game Won", [
                    "winning_player_name": gameState.currentPlayerName
                ]
            )
        }

        if case let .newGame(newGameState) = state,
            let gameState = newGameState.game,
            gameState.board.hasWinner == false,
           gameState.board.isFilled {
            environment.trackingClient.track(
                "Game Tied", [
                    "x_player_name": gameState.xPlayerName,
                    "o_player_name": gameState.oPlayerName
                ]
            )
        }

        return .none

    case .newGame(.game(.quitButtonTapped)):
        if case let .newGame(newGameState) = state {
            environment.trackingClient.track("Quit Playing", [
                "x_player_name": newGameState.xPlayerName,
                "o_player_name": newGameState.oPlayerName
            ])
        }
        return .none

    case .newGame(.game(.playAgainButtonTapped)):
        if case let .newGame(newGameState) = state {
            environment.trackingClient.track("Rematch", [
                "x_player_name": newGameState.xPlayerName,
                "o_player_name": newGameState.oPlayerName
            ])
        }

        return .none

    case .newGame(.letsPlayButtonTapped):
        if case let .newGame(newGameState) = state {
            // Identify both players uniquely
            // This probably shouldn't be used back-to-back like this
            //environment.trackingClient.identify(newGameState.xPlayerUniqueID, ["user_name": newGameState.xPlayerName])
            //environment.trackingClient.identify(newGameState.oPlayerUniqueID, ["user_name": newGameState.oPlayerName])

            environment.trackingClient.track("New Game Started", [
                "x_player_name": newGameState.xPlayerName,
                "o_player_name": newGameState.oPlayerName
            ])
        }

        return .none

    case let .login(.loginResponse(.failure(error))):
        environment.trackingClient.track("Login failed", [
            "error_message": error.localizedDescription,
        ])
        return .none

    case let .login(.twoFactor(.twoFactorResponse(.failure(error)))):
        environment.trackingClient.track("2FA Login failed", ["error_message": error.localizedDescription])
        return .none

    case let .login(.twoFactor(.twoFactorResponse(.success(response)))),
        let .login(.loginResponse(.success(response))) where !response.twoFactorRequired:

        if case let .login(loginState) = state {
            // Track successfull login
            environment.trackingClient.track("Login success", nil)

            // Identify logged in user with identify (better to use some unique system id)

            // Random UUID created for testing unique user
//            environment.trackingClient.identify("8bbd33f0-39c9-11ed-a261-0242ac120002", ["user_email": loginState.email])
        }

        return .none

    case .newGame(.logoutButtonTapped):
        environment.trackingClient.track("Logout success", nil)
        return .none

    default:
        return .none
    }
}
