import ComposableArchitecture
import GameCore

/// Faked Unique IDs for players by name
///
func uniqueId(for playerName: String) -> String {
    let ids = [
        "Travis": "3e69b53f-fa64-4fa5-9baa-5d223ad5bf17",
        "Renato": "dacdcc14-ae5e-4d57-a971-04471afea2a8",
        "Tiago": "d9b73cfd-0225-40e3-8c4b-f1ee9c9f7e61",
        "Andre": "05b1da8d-560f-43a4-8443-572828a3a91e",
        "Guilherme": "bcf7c40c-77d3-4a7a-b0bc-d3c6a4668d86",
        "Jacob": "5f0165ef-0ac7-49d4-8ca0-7e6089ea002a",
        "Daniel": "9e8467ad-5904-4026-8f6f-bf8533803a5f",
        "Aaron": "fb859053-fc90-4bcb-b322-7a646dd16b3c",
        "Francisco": "a92ac126-8a58-4c7a-8c34-646aa86b6464",
        "Kim": "2eb172bf-a317-4257-aac8-1c9ee8cb219b",
        "Kanye": "219023ef-3116-4972-bab2-3670b1798d74",
    ]

    guard let id = ids[playerName] else {
        return "00000000-0000-0000-0000-000000000000"
    }

    return id
}

public struct NewGameState: Equatable {
  public var game: GameState?
  public var oPlayerName = ""
  public var xPlayerName = ""

  public init() {}

    public var oPlayerUniqueID: String {
        uniqueId(for: self.oPlayerName)
    }

    public var xPlayerUniqueID: String {
        uniqueId(for: self.xPlayerName)
    }
}

public enum NewGameAction: Equatable {
  case game(GameAction)
  case gameDismissed
  case letsPlayButtonTapped
  case logoutButtonTapped
  case oPlayerNameChanged(String)
  case xPlayerNameChanged(String)
}

public struct NewGameEnvironment {
  public init() {}
}

public let newGameReducer = Reducer<NewGameState, NewGameAction, NewGameEnvironment>.combine(
  gameReducer
    .optional()
    .pullback(
      state: \.game,
      action: /NewGameAction.game,
      environment: { _ in GameEnvironment() }
    ),

  .init { state, action, _ in
    switch action {
    case .game(.quitButtonTapped):
      state.game = nil
      return .none

    case .gameDismissed:
      state.game = nil
      return .none

    case .game:
      return .none

    case .letsPlayButtonTapped:
      state.game = GameState(
        oPlayerName: state.oPlayerName,
        xPlayerName: state.xPlayerName
      )
      return .none

    case .logoutButtonTapped:
      return .none

    case let .oPlayerNameChanged(name):
      state.oPlayerName = name
      return .none

    case let .xPlayerNameChanged(name):
      state.xPlayerName = name
      return .none
    }
  }
)
