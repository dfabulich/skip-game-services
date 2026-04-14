// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
#if SKIP

import SwiftUI

// MARK: - GKPlayer (GKPlayer.swift header)

extension GKPlayer {
    // SKIP @nobridge
    public enum PhotoSize: Int, @unchecked Sendable {
        case small = 0
        case normal = 1
    }

    @available(*, unavailable)
    open func loadPhoto(
        for size: GKPlayer.PhotoSize,
        withCompletionHandler completionHandler: @escaping @Sendable (UIImage?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadPhoto(for size: GKPlayer.PhotoSize) async throws -> UIImage {
        fatalError()
    }

    @available(*, unavailable)
    open var isFriend: Bool { fatalError() }

    open class func loadPlayers(
        forIdentifiers identifiers: [String],
        withCompletionHandler completionHandler: @escaping @Sendable ([GKPlayer]?, (any Error)?) -> Void
    ) {
        fatalError()
    }
}

// MARK: - GKVoiceChat (GKVoiceChat.swift header)

extension GKVoiceChat {
    public enum PlayerState: Int, @unchecked Sendable {
        case connected = 0
        case disconnected = 1
        case speaking = 2
        case silent = 3
        case connecting = 4
    }
}

open class GKVoiceChat: NSObject {
    @available(*, unavailable)
    open func start() { fatalError() }

    @available(*, unavailable)
    open func stop() { fatalError() }

    @available(*, unavailable)
    open func setPlayer(_ player: GKPlayer, muted isMuted: Bool) { fatalError() }

    @available(*, unavailable)
    open var playerVoiceChatStateDidChangeHandler: (GKPlayer, GKVoiceChat.PlayerState) -> Void {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var name: String { fatalError() }

    @available(*, unavailable)
    open var isActive: Bool {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var volume: Float {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var players: [GKPlayer] { fatalError() }

    open class func isVoIPAllowed() -> Bool { fatalError() }

    @available(*, unavailable)
    open var playerStateUpdateHandler: (String, GKVoiceChat.PlayerState) -> Void {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var playerIDs: [String]? { fatalError() }

    @available(*, unavailable)
    open func setMute(_ isMuted: Bool, forPlayer playerID: String) { fatalError() }
}

// MARK: - GKNotificationBanner (GKNotificationBanner.swift header)

open class GKNotificationBanner: NSObject {
    open class func show(
        withTitle title: String?,
        message: String?,
        completionHandler: @escaping @Sendable () -> Void
    ) {
        fatalError()
    }

    open class func show(withTitle title: String?, message: String?) async {
        fatalError()
    }

    open class func show(
        withTitle title: String?,
        message: String?,
        duration: TimeInterval,
        completionHandler: @escaping @Sendable () -> Void
    ) {
        fatalError()
    }

    open class func show(withTitle title: String?, message: String?, duration: TimeInterval) async {
        fatalError()
    }
}

// MARK: - GKCloudPlayer (GKCloudPlayer.swift header)

open class GKCloudPlayer: GKBasePlayer {
    open class func getCurrentSignedInPlayer(
        forContainer containerName: String?,
        completionHandler handler: @escaping @Sendable (GKCloudPlayer?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    open class func currentSignedInPlayer(forContainer containerName: String?) async throws -> GKCloudPlayer {
        fatalError()
    }
}

// MARK: - GKLeaderboardScore (GKLeaderboardScore header)

open class GKLeaderboardScore: NSObject, Hashable {
    @available(*, unavailable)
    open var player: GKPlayer {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var value: Int {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var context: Int {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var leaderboardID: String {
        get { fatalError() }
        set { fatalError() }
    }

    public static func == (lhs: GKLeaderboardScore, rhs: GKLeaderboardScore) -> Bool {
        lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }
}

// MARK: - GKPlayerConnectionState, GKMatch (GKMatch.swift header)

public enum GKPlayerConnectionState: Int, @unchecked Sendable {
    case unknown = 0
    case connected = 1
    case disconnected = 2
}

public protocol GKMatchDelegate: NSObjectProtocol {}

extension GKMatch {
    public enum SendDataMode: Int, @unchecked Sendable {
        case reliable = 0
        case unreliable = 1
    }
}

open class GKMatch: NSObject {
    @available(*, unavailable)
    open var players: [GKPlayer] { fatalError() }

    @available(*, unavailable)
    weak open var delegate: (any GKMatchDelegate)? {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var expectedPlayerCount: Int { fatalError() }

    @available(*, unavailable)
    open var properties: [String: Any]? { fatalError() }

    @available(*, unavailable)
    open var playerProperties: [GKPlayer: [String: Any]]? { fatalError() }

    @available(*, unavailable)
    open func send(_ data: Data, to players: [GKPlayer], dataMode mode: GKMatch.SendDataMode) throws {
        fatalError()
    }

    @available(*, unavailable)
    open func sendData(toAllPlayers data: Data, with mode: GKMatch.SendDataMode) throws {
        fatalError()
    }

    @available(*, unavailable)
    open func disconnect() { fatalError() }

    @available(*, unavailable)
    open func chooseBestHostingPlayer(completionHandler: @escaping @Sendable (GKPlayer?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open func chooseBestHostingPlayer() async -> GKPlayer? {
        fatalError()
    }

    @available(*, unavailable)
    open func rematch(completionHandler: @escaping @Sendable (GKMatch?, (any Error)?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open func rematch() async throws -> GKMatch {
        fatalError()
    }

    @available(*, unavailable)
    open func voiceChat(withName name: String) -> GKVoiceChat? {
        fatalError()
    }

    @available(*, unavailable)
    open func chooseBestHostPlayer(completionHandler: @escaping @Sendable (String?) -> Void) {
        fatalError()
    }

    /// Kotlin/JVM: non-`open` to avoid overload clash with ``send(_:to:dataMode:)``.
    @available(*, unavailable)
    public func send(_ data: Data, toPlayers playerIDs: [String], with mode: GKMatch.SendDataMode) throws {
        fatalError()
    }

    @available(*, unavailable)
    open var playerIDs: [String]? { fatalError() }
}

// MARK: - GKMatchmaker stack (GKMatchMaker.swift header)

public enum GKInviteRecipientResponse: Int, @unchecked Sendable {
    case accepted = 0
    case declined = 1
    case failed = 2
    case incompatible = 3
    case unableToConnect = 4
    case noAnswer = 5
}

public typealias GKInviteeResponse = GKInviteRecipientResponse

open class GKMatchRequest: NSObject {
    @available(*, unavailable)
    open var minPlayers: Int {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var maxPlayers: Int {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var playerGroup: Int {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var playerAttributes: UInt32 {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var recipients: [GKPlayer]? {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var inviteMessage: String? {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var defaultNumberOfPlayers: Int {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var restrictToAutomatch: Bool {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var recipientResponseHandler: ((GKPlayer, GKInviteRecipientResponse) -> Void)? {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var inviteeResponseHandler: ((String, GKInviteeResponse) -> Void)? {
        get { fatalError() }
        set { fatalError() }
    }

    open class func maxPlayersAllowedForMatch(of matchType: GKMatchType) -> Int {
        fatalError()
    }

    @available(*, unavailable)
    open var playersToInvite: [String]? {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var queueName: String? {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var properties: [String: Any]? {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var recipientProperties: [GKPlayer: [String: Any]]? {
        get { fatalError() }
        set { fatalError() }
    }
}

public enum GKMatchType: UInt, @unchecked Sendable {
    case peerToPeer = 0
    case hosted = 1
    case turnBased = 2
}

extension GKInvite {
    @available(*, unavailable)
    open var sender: GKPlayer { fatalError() }

    @available(*, unavailable)
    open var isHosted: Bool { fatalError() }

    @available(*, unavailable)
    open var playerGroup: Int { fatalError() }

    @available(*, unavailable)
    open var playerAttributes: UInt32 { fatalError() }

    @available(*, unavailable)
    open var inviter: String { fatalError() }
}

open class GKMatchedPlayers: NSObject {
    @available(*, unavailable)
    open var properties: [String: Any]? { fatalError() }

    @available(*, unavailable)
    open var players: [GKPlayer] { fatalError() }

    @available(*, unavailable)
    open var playerProperties: [GKPlayer: [String: Any]]? { fatalError() }
}

open class GKMatchmaker: NSObject {
    open class func shared() -> GKMatchmaker { fatalError() }

    @available(*, unavailable)
    open func match(
        for invite: GKInvite,
        completionHandler: @escaping @Sendable (GKMatch?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func match(for invite: GKInvite) async throws -> GKMatch {
        fatalError()
    }

    @available(*, unavailable)
    open func findMatch(
        for request: GKMatchRequest,
        withCompletionHandler completionHandler: @escaping @Sendable (GKMatch?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func findMatch(for request: GKMatchRequest) async throws -> GKMatch {
        fatalError()
    }

    @available(*, unavailable)
    open func findPlayers(
        forHostedRequest request: GKMatchRequest,
        withCompletionHandler completionHandler: @escaping @Sendable ([GKPlayer]?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func findPlayers(forHostedRequest request: GKMatchRequest) async throws -> [GKPlayer] {
        fatalError()
    }

    @available(*, unavailable)
    open func findMatchedPlayers(
        _ request: GKMatchRequest,
        withCompletionHandler completionHandler: @escaping @Sendable (GKMatchedPlayers?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func findMatchedPlayers(_ request: GKMatchRequest) async throws -> GKMatchedPlayers {
        fatalError()
    }

    @available(*, unavailable)
    open func addPlayers(
        to match: GKMatch,
        matchRequest: GKMatchRequest,
        completionHandler: @escaping @Sendable ((any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func addPlayers(to match: GKMatch, matchRequest: GKMatchRequest) async throws {
        fatalError()
    }

    @available(*, unavailable)
    open func cancel() { fatalError() }

    @available(*, unavailable)
    open func cancelPendingInvite(to player: GKPlayer) { fatalError() }

    @available(*, unavailable)
    open func finishMatchmaking(for match: GKMatch) { fatalError() }

    @available(*, unavailable)
    open func queryPlayerGroupActivity(
        _ playerGroup: Int,
        withCompletionHandler completionHandler: @escaping @Sendable (Int, (any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func queryPlayerGroupActivity(_ playerGroup: Int) async throws -> Int {
        fatalError()
    }

    @available(*, unavailable)
    open func queryActivity(completionHandler: @escaping @Sendable (Int, (any Error)?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open func queryActivity() async throws -> Int {
        fatalError()
    }

    @available(*, unavailable)
    open func queryQueueActivity(
        _ queueName: String,
        withCompletionHandler completionHandler: @escaping @Sendable (Int, (any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func queryQueueActivity(_ queueName: String) async throws -> Int {
        fatalError()
    }

    @available(*, unavailable)
    open func startBrowsingForNearbyPlayers(handler reachableHandler: ((GKPlayer, Bool) -> Void)?) {
        fatalError()
    }

    @available(*, unavailable)
    open func stopBrowsingForNearbyPlayers() { fatalError() }

    @available(*, unavailable)
    open func startGroupActivity(playerHandler handler: @escaping (GKPlayer) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open func stopGroupActivity() { fatalError() }

#if false // Legacy String-ID overloads clash on JVM with GKPlayer-based variants.
    @available(*, unavailable)
    open func startBrowsingForNearbyPlayers(reachableHandler: ((String, Bool) -> Void)?) {
        fatalError()
    }

    @available(*, unavailable)
    open func cancelInvite(toPlayer playerID: String) { fatalError() }

    @available(*, unavailable)
    open func findPlayers(
        forHostedMatchRequest request: GKMatchRequest,
        withCompletionHandler completionHandler: @escaping @Sendable ([String]?, (any Error)?) -> Void
    ) {
        fatalError()
    }
#endif
}

open class GKLeaderboardSet: NSObject {
    @available(*, unavailable)
    open var title: String { fatalError() }

    @available(*, unavailable)
    open var groupIdentifier: String? { fatalError() }

    @available(*, unavailable)
    open var identifier: String? {
        get { fatalError() }
        set { fatalError() }
    }

    open class func loadLeaderboardSets(
        completionHandler: @escaping @Sendable ([GKLeaderboardSet]?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    open class func loadLeaderboardSets() async throws -> [GKLeaderboardSet] {
        fatalError()
    }

#if false // Deprecated overload causes Kotlin signature conflicts with completionHandler variant.
    @available(*, unavailable)
    open func loadLeaderboards(handler: @escaping ([GKLeaderboard]?, (any Error)?) -> Void) {
        fatalError()
    }
#endif

    @available(*, unavailable)
    open func loadLeaderboards(
        completionHandler: @escaping @Sendable ([GKLeaderboard]?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadLeaderboards() async throws -> [GKLeaderboard] {
        fatalError()
    }

    @available(*, unavailable)
    open func loadImage(completionHandler: @escaping @Sendable (UIImage?, (any Error)?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadImage() async throws -> UIImage {
        fatalError()
    }
}

// MARK: - GKTurnBasedMatch (GKTurnBasedMatch.swift header)

@available(*, unavailable)
public let GKTurnTimeoutDefault: TimeInterval = 0

@available(*, unavailable)
public let GKTurnTimeoutNone: TimeInterval = 0

@available(*, unavailable)
public let GKExchangeTimeoutDefault: TimeInterval = 0

@available(*, unavailable)
public let GKExchangeTimeoutNone: TimeInterval = 0

extension GKTurnBasedMatch {
    // SKIP @nobridge
    public enum Status: Int, @unchecked Sendable {
        case unknown = 0
        //case open = 1
        case ended = 2
        case matching = 3
    }

    // SKIP @nobridge
    public enum Outcome: Int, @unchecked Sendable {
        case none = 0
        case quit = 1
        case won = 2
        case lost = 3
        case tied = 4
        case timeExpired = 5
        case first = 6
        case second = 7
        case third = 8
        case fourth = 9
        case customRange = 16711680
    }
}
extension GKTurnBasedParticipant {
    public enum Status: Int, @unchecked Sendable {
        case unknown = 0
        case invited = 1
        case declined = 2
        case matching = 3
        case active = 4
        case done = 5
    }
}

open class GKTurnBasedParticipant: NSObject {
    @available(*, unavailable)
    open var player: GKPlayer? { fatalError() }

    @available(*, unavailable)
    open var lastTurnDate: Date? { fatalError() }

    @available(*, unavailable)
    open var status: GKTurnBasedParticipant.Status { fatalError() }

    @available(*, unavailable)
    open var matchOutcome: GKTurnBasedMatch.Outcome {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var timeoutDate: Date? { fatalError() }

    @available(*, unavailable)
    open var playerID: String? { fatalError() }
}

public enum GKTurnBasedExchangeStatus: Int, @unchecked Sendable {
    case unknown = 0
    case active = 1
    case complete = 2
    case resolved = 3
    case canceled = 4
}

open class GKTurnBasedExchangeReply: NSObject {
    @available(*, unavailable)
    open var recipient: GKTurnBasedParticipant { fatalError() }

    @available(*, unavailable)
    open var message: String? { fatalError() }

    @available(*, unavailable)
    open var data: Data? { fatalError() }

    @available(*, unavailable)
    open var replyDate: Date { fatalError() }
}

open class GKTurnBasedExchange: NSObject {
    @available(*, unavailable)
    open var exchangeID: String { fatalError() }

    @available(*, unavailable)
    open var sender: GKTurnBasedParticipant { fatalError() }

    @available(*, unavailable)
    open var recipients: [GKTurnBasedParticipant] { fatalError() }

    @available(*, unavailable)
    open var status: GKTurnBasedExchangeStatus { fatalError() }

    @available(*, unavailable)
    open var message: String? { fatalError() }

    @available(*, unavailable)
    open var data: Data? { fatalError() }

    @available(*, unavailable)
    open var sendDate: Date { fatalError() }

    @available(*, unavailable)
    open var timeoutDate: Date? { fatalError() }

    @available(*, unavailable)
    open var completionDate: Date? { fatalError() }

    @available(*, unavailable)
    open var replies: [GKTurnBasedExchangeReply]? { fatalError() }

    @available(*, unavailable)
    open func cancel(
        withLocalizableMessageKey key: String,
        arguments: [String],
        completionHandler: @escaping @Sendable ((any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func cancel(withLocalizableMessageKey key: String, arguments: [String]) async throws {
        fatalError()
    }

    @available(*, unavailable)
    open func reply(
        withLocalizableMessageKey key: String,
        arguments: [String],
        data: Data,
        completionHandler: @escaping @Sendable ((any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func reply(
        withLocalizableMessageKey key: String,
        arguments: [String],
        data: Data
    ) async throws {
        fatalError()
    }
}

extension GKTurnBasedMatch {
    @available(*, unavailable)
    open var matchID: String { fatalError() }

    @available(*, unavailable)
    open var creationDate: Date { fatalError() }

    @available(*, unavailable)
    open var participants: [GKTurnBasedParticipant] { fatalError() }

    @available(*, unavailable)
    open var status: GKTurnBasedMatch.Status { fatalError() }

    @available(*, unavailable)
    open var currentParticipant: GKTurnBasedParticipant? { fatalError() }

    @available(*, unavailable)
    open var matchData: Data? { fatalError() }

    @available(*, unavailable)
    open func setLocalizableMessageWithKey(_ key: String, arguments: [String]?) { fatalError() }

    @available(*, unavailable)
    open var message: String? {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var matchDataMaximumSize: Int { fatalError() }

    @available(*, unavailable)
    open var exchanges: [GKTurnBasedExchange]? { fatalError() }

    @available(*, unavailable)
    open var activeExchanges: [GKTurnBasedExchange]? { fatalError() }

    @available(*, unavailable)
    open var completedExchanges: [GKTurnBasedExchange]? { fatalError() }

    @available(*, unavailable)
    open var exchangeDataMaximumSize: Int { fatalError() }

    @available(*, unavailable)
    open var exchangeMaxInitiatedExchangesPerPlayer: Int { fatalError() }

    open class func find(
        for request: GKMatchRequest,
        withCompletionHandler completionHandler: @escaping @Sendable (GKTurnBasedMatch?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    open class func find(for request: GKMatchRequest) async throws -> GKTurnBasedMatch {
        fatalError()
    }

    open class func loadMatches(
        completionHandler: @escaping @Sendable ([GKTurnBasedMatch]?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    open class func loadMatches() async throws -> [GKTurnBasedMatch] {
        fatalError()
    }

    open class func load(
        withID matchID: String,
        withCompletionHandler completionHandler: @escaping @Sendable (GKTurnBasedMatch?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    open class func load(withID matchID: String) async throws -> GKTurnBasedMatch {
        fatalError()
    }

    @available(*, unavailable)
    open func rematch(
        completionHandler: @escaping @Sendable (GKTurnBasedMatch?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func rematch() async throws -> GKTurnBasedMatch {
        fatalError()
    }

    @available(*, unavailable)
    open func acceptInvite(
        completionHandler: @escaping @Sendable (GKTurnBasedMatch?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func acceptInvite() async throws -> GKTurnBasedMatch {
        fatalError()
    }

    @available(*, unavailable)
    open func declineInvite(completionHandler: @escaping @Sendable ((any Error)?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open func declineInvite() async throws {
        fatalError()
    }

    @available(*, unavailable)
    open func remove(completionHandler: @escaping @Sendable ((any Error)?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open func remove() async throws {
        fatalError()
    }

    @available(*, unavailable)
    open func loadMatchData(completionHandler: @escaping @Sendable (Data?, (any Error)?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadMatchData() async throws -> Data? {
        fatalError()
    }

    @available(*, unavailable)
    open func endTurn(
        withNextParticipants nextParticipants: [GKTurnBasedParticipant],
        turnTimeout timeout: TimeInterval,
        match matchData: Data,
        completionHandler: @escaping @Sendable ((any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func endTurn(
        withNextParticipants nextParticipants: [GKTurnBasedParticipant],
        turnTimeout timeout: TimeInterval,
        match matchData: Data
    ) async throws {
        fatalError()
    }

    @available(*, unavailable)
    open func participantQuitInTurn(
        with matchOutcome: GKTurnBasedMatch.Outcome,
        nextParticipants: [GKTurnBasedParticipant],
        turnTimeout timeout: TimeInterval,
        match matchData: Data,
        completionHandler: @escaping @Sendable ((any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func participantQuitInTurn(
        with matchOutcome: GKTurnBasedMatch.Outcome,
        nextParticipants: [GKTurnBasedParticipant],
        turnTimeout timeout: TimeInterval,
        match matchData: Data
    ) async throws {
        fatalError()
    }

    @available(*, unavailable)
    open func participantQuitOutOfTurn(
        with matchOutcome: GKTurnBasedMatch.Outcome,
        withCompletionHandler completionHandler: @escaping @Sendable ((any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func participantQuitOutOfTurn(with matchOutcome: GKTurnBasedMatch.Outcome) async throws {
        fatalError()
    }

    @available(*, unavailable)
    open func endMatchInTurn(
        withMatch matchData: Data,
        completionHandler: @escaping @Sendable ((any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func endMatchInTurn(withMatch matchData: Data) async throws {
        fatalError()
    }

    
    #if false // deprecated GKScore variants clash with GKLeaderboardScore variants
    @available(*, unavailable)
    open func endMatchInTurn(
        withMatch matchData: Data,
        scores: [GKScore]?,
        achievements: [GKAchievement]?,
        completionHandler: @escaping @Sendable ((any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func endMatchInTurn(
        withMatch matchData: Data,
        scores: [GKScore]?,
        achievements: [GKAchievement]?
    ) async throws {
        fatalError()
    }
    #endif

    @available(*, unavailable)
    open func endMatchInTurn(
        withMatch matchData: Data,
        leaderboardScores scores: [GKLeaderboardScore],
        achievements: [Any],
        completionHandler: @escaping @Sendable ((any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func endMatchInTurn(
        withMatch matchData: Data,
        leaderboardScores scores: [GKLeaderboardScore],
        achievements: [Any]
    ) async throws {
        fatalError()
    }

    @available(*, unavailable)
    open func saveCurrentTurn(
        withMatch matchData: Data,
        completionHandler: @escaping @Sendable ((any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func saveCurrentTurn(withMatch matchData: Data) async throws {
        fatalError()
    }

    @available(*, unavailable)
    open func saveMergedMatch(
        _ matchData: Data,
        withResolvedExchanges exchanges: [GKTurnBasedExchange],
        completionHandler: @escaping @Sendable ((any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func saveMergedMatch(
        _ matchData: Data,
        withResolvedExchanges exchanges: [GKTurnBasedExchange]
    ) async throws {
        fatalError()
    }

    @available(*, unavailable)
    open func sendExchange(
        to participants: [GKTurnBasedParticipant],
        data: Data,
        localizableMessageKey key: String,
        arguments: [String],
        timeout: TimeInterval,
        completionHandler: @escaping @Sendable (GKTurnBasedExchange?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func sendExchange(
        to participants: [GKTurnBasedParticipant],
        data: Data,
        localizableMessageKey key: String,
        arguments: [String],
        timeout: TimeInterval
    ) async throws -> GKTurnBasedExchange {
        fatalError()
    }

    @available(*, unavailable)
    open func sendReminder(
        to participants: [GKTurnBasedParticipant],
        localizableMessageKey key: String,
        arguments: [String],
        completionHandler: @escaping @Sendable ((any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func sendReminder(
        to participants: [GKTurnBasedParticipant],
        localizableMessageKey key: String,
        arguments: [String]
    ) async throws {
        fatalError()
    }
}

// MARK: - GKChallenge (GKChallenge.swift header)

public enum GKChallengeState: Int, @unchecked Sendable {
    case invalid = 0
    case pending = 1
    case completed = 2
    case declined = 3
}

extension GKChallenge {
    open class func loadReceivedChallenges(
        completionHandler: @escaping @Sendable ([GKChallenge]?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    open class func loadReceivedChallenges() async throws -> [GKChallenge] {
        fatalError()
    }

    @available(*, unavailable)
    open func decline() { fatalError() }

    @available(*, unavailable)
    open var issuingPlayer: GKPlayer? { fatalError() }

    @available(*, unavailable)
    open var receivingPlayer: GKPlayer? { fatalError() }

    @available(*, unavailable)
    open var state: GKChallengeState { fatalError() }

    @available(*, unavailable)
    open var issueDate: Date { fatalError() }

    @available(*, unavailable)
    open var completionDate: Date? { fatalError() }

    @available(*, unavailable)
    open var message: String? { fatalError() }

    @available(*, unavailable)
    open var issuingPlayerID: String? { fatalError() }

    @available(*, unavailable)
    open var receivingPlayerID: String? { fatalError() }
}

open class GKScoreChallenge: GKChallenge {
    @available(*, unavailable)
    open var score: GKScore? { fatalError() }

    @available(*, unavailable)
    open var leaderboardEntry: GKLeaderboard.Entry? { fatalError() }
}

open class GKAchievementChallenge: GKChallenge {
    @available(*, unavailable)
    open var achievement: GKAchievement? { fatalError() }
}

extension GKScore {
    #if false // deprecated GKScore variants clash with GKLeaderboardScore variants
    open class func report(
        _ scores: [GKScore],
        withEligibleChallenges challenges: [GKChallenge],
        withCompletionHandler completionHandler: @escaping @Sendable ((any Error)?) -> Void
    ) {
        fatalError()
    }

    open class func report(
        _ scores: [GKScore],
        withEligibleChallenges challenges: [GKChallenge]
    ) async throws {
        fatalError()
    }

    #endif
    open class func report(
        _ scores: [GKLeaderboardScore],
        withEligibleChallenges challenges: [GKChallenge],
        withCompletionHandler completionHandler: @escaping @Sendable ((any Error)?) -> Void
    ) {
        fatalError()
    }

    open class func report(
        _ scores: [GKLeaderboardScore],
        withEligibleChallenges challenges: [GKChallenge]
    ) async throws {
        fatalError()
    }

    #if false // UIViewController-based compose APIs are not bridged in Skip.
    @available(*, unavailable)
    open func challengeComposeController(
        withMessage message: String?,
        players: [GKPlayer]?,
        completionHandler: GKChallengeComposeCompletionBlock?
    ) -> UIViewController {
        fatalError()
    }

    @available(*, unavailable)
    open func challengeComposeController(
        withMessage message: String?,
        players: [GKPlayer]?,
        completion completionHandler: GKChallengeComposeHandler?
    ) -> UIViewController {
        fatalError()
    }

    @available(*, unavailable)
    open func challengeComposeController(
        withPlayers playerIDs: [String]?,
        message: String?,
        completionHandler: GKChallengeComposeCompletionBlock?
    ) -> UIViewController? {
        fatalError()
    }
    #endif
}

extension GKAchievement {
    @available(*, unavailable)
    open func selectChallengeablePlayers(
        _ players: [GKPlayer],
        withCompletionHandler completionHandler: @escaping @Sendable ([GKPlayer]?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func selectChallengeablePlayers(_ players: [GKPlayer]) async throws -> [GKPlayer] {
        fatalError()
    }

    open class func report(
        _ achievements: [GKAchievement],
        withEligibleChallenges challenges: [GKChallenge],
        withCompletionHandler completionHandler: @escaping @Sendable ((any Error)?) -> Void
    ) {
        fatalError()
    }

    open class func report(
        _ achievements: [GKAchievement],
        withEligibleChallenges challenges: [GKChallenge]
    ) async throws {
        fatalError()
    }

    @available(*, unavailable)
    open func selectChallengeablePlayerIDs(
        _ playerIDs: [String]?,
        withCompletionHandler completionHandler: @escaping @Sendable ([String]?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    #if false // UIViewController-based compose APIs are not bridged in Skip.
    @available(*, unavailable)
    open func challengeComposeController(
        withMessage message: String?,
        players: [GKPlayer],
        completionHandler: GKChallengeComposeCompletionBlock?
    ) -> UIViewController {
        fatalError()
    }

    @available(*, unavailable)
    open func challengeComposeController(
        withMessage message: String?,
        players: [GKPlayer],
        completion completionHandler: GKChallengeComposeHandler?
    ) -> UIViewController {
        fatalError()
    }

    @available(*, unavailable)
    open func challengeComposeController(
        withPlayers playerIDs: [String]?,
        message: String?,
        completionHandler: GKChallengeComposeCompletionBlock?
    ) -> UIViewController? {
        fatalError()
    }
    #endif
}

// MARK: - GKChallengeDefinition (GKChallengeDefinition.swift header)

open class GKChallengeDefinition: NSObject {
    @available(*, unavailable)
    open var identifier: String { fatalError() }

    @available(*, unavailable)
    open var groupIdentifier: String? { fatalError() }

    @available(*, unavailable)
    open var title: String { fatalError() }

    @available(*, unavailable)
    open var details: String? { fatalError() }

    @available(*, unavailable)
    open var durationOptions: [DateComponents] { fatalError() }

    @available(*, unavailable)
    open var isRepeatable: Bool { fatalError() }

    @available(*, unavailable)
    open var leaderboard: GKLeaderboard? { fatalError() }

    @available(*, unavailable)
    open var releaseState: GKReleaseState { fatalError() }

    @available(*, unavailable)
    open func loadImage(completionHandler: @escaping @Sendable (UIImage?, (any Error)?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open var image: UIImage? {
        get async throws {
            fatalError()
        }
    }
}

extension GKChallengeDefinition {
    open class func loadChallengeDefinitions(
        completionHandler: @escaping @Sendable ([GKChallengeDefinition]?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    open class var all: [GKChallengeDefinition] {
        get async throws {
            fatalError()
        }
    }

    @available(*, unavailable)
    open func hasActiveChallenges(completionHandler: @escaping @Sendable (Bool, (any Error)?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open var hasActiveChallenges: Bool {
        get async throws {
            fatalError()
        }
    }
}

// MARK: - GKGameActivity (GKGameActivity*.swift headers)

public enum GKGameActivityPlayStyle: Int, @unchecked Sendable {
    case unspecified = 0
    case synchronous = 1
    case asynchronous = 2
}

extension GKGameActivity {
    // SKIP @nobridge
    public enum State: UInt, @unchecked Sendable {
        case initialized = 0
        case active = 1
        case paused = 2
        case ended = 4
    }
}

open class GKGameActivityDefinition: NSObject {
    @available(*, unavailable)
    open var identifier: String { fatalError() }

    @available(*, unavailable)
    open var groupIdentifier: String? { fatalError() }

    @available(*, unavailable)
    open var title: String { fatalError() }

    @available(*, unavailable)
    open var details: String? { fatalError() }

    @available(*, unavailable)
    open var defaultProperties: [String: String] { fatalError() }

    @available(*, unavailable)
    open var fallbackURL: URL? { fatalError() }

    @available(*, unavailable)
    open var supportsPartyCode: Bool { fatalError() }

    @available(*, unavailable)
    open var supportsUnlimitedPlayers: Bool { fatalError() }

    @available(*, unavailable)
    open var playStyle: GKGameActivityPlayStyle { fatalError() }

    @available(*, unavailable)
    open var releaseState: GKReleaseState { fatalError() }

    @available(*, unavailable)
    open func loadAchievementDescriptions(
        completionHandler: @escaping @Sendable ([GKAchievementDescription]?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open var achievementDescriptions: [GKAchievementDescription] {
        get async throws {
            fatalError()
        }
    }

    @available(*, unavailable)
    open func loadLeaderboards(
        completionHandler: @escaping @Sendable ([GKLeaderboard]?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open var leaderboards: [GKLeaderboard] {
        get async throws {
            fatalError()
        }
    }

    @available(*, unavailable)
    open func loadImage(completionHandler: @escaping @Sendable (UIImage?, (any Error)?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open var image: UIImage? {
        get async throws {
            fatalError()
        }
    }
}

extension GKGameActivityDefinition {
    @available(*, unavailable)
    final public var playerRange: ClosedRange<Int>? {
        fatalError()
    }

    open class func loadGameActivityDefinitions(
        completionHandler: @escaping @Sendable ([GKGameActivityDefinition]?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    open class var all: [GKGameActivityDefinition] {
        get async throws {
            fatalError()
        }
    }

    open class func loadGameActivityDefinitions(
        IDs activityDefinitionIDs: [String]?,
        completionHandler: @escaping @Sendable ([GKGameActivityDefinition]?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    open class func loadGameActivityDefinitions(IDs activityDefinitionIDs: [String]?) async throws
        -> [GKGameActivityDefinition]
    {
        fatalError()
    }
}

extension GKGameActivity {
    @available(*, unavailable)
    open var identifier: String { fatalError() }

    @available(*, unavailable)
    open var activityDefinition: GKGameActivityDefinition { fatalError() }

    @available(*, unavailable)
    open var properties: [String: String] {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var state: GKGameActivity.State { fatalError() }

    @available(*, unavailable)
    open var partyCode: String? { fatalError() }

    @available(*, unavailable)
    open var partyURL: URL? { fatalError() }

    @available(*, unavailable)
    open var creationDate: Date { fatalError() }

    @available(*, unavailable)
    open var startDate: Date? { fatalError() }

    @available(*, unavailable)
    open var lastResumeDate: Date? { fatalError() }

    @available(*, unavailable)
    open var endDate: Date? { fatalError() }

    @available(*, unavailable)
    open var duration: TimeInterval { fatalError() }

    @available(*, unavailable)
    open var achievements: Set<GKAchievement> { fatalError() }

    @available(*, unavailable)
    open var leaderboardScores: Set<GKLeaderboardScore> { fatalError() }

    open class var validPartyCodeAlphabet: [String] { fatalError() }

    open class func start(definition activityDefinition: GKGameActivityDefinition, partyCode: String) throws
        -> GKGameActivity
    {
        fatalError()
    }

    open class func start(definition activityDefinition: GKGameActivityDefinition) throws -> GKGameActivity {
        fatalError()
    }

    open class func isValidPartyCode(_ partyCode: String) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public convenience init(definition activityDefinition: GKGameActivityDefinition) {
        fatalError()
    }

    @available(*, unavailable)
    open func start() { fatalError() }

    @available(*, unavailable)
    open func pause() { fatalError() }

    @available(*, unavailable)
    open func resume() { fatalError() }

    @available(*, unavailable)
    open func end() { fatalError() }

    @available(*, unavailable)
    open func setScore(on leaderboard: GKLeaderboard, to score: Int, context: Int) { fatalError() }

    @available(*, unavailable)
    open func setScore(on leaderboard: GKLeaderboard, to score: Int) { fatalError() }

    @available(*, unavailable)
    open func score(on leaderboard: GKLeaderboard) -> GKLeaderboardScore? {
        fatalError()
    }

    @available(*, unavailable)
    open func removeScores(from leaderboards: [GKLeaderboard]) { fatalError() }

    @available(*, unavailable)
    open func setProgress(on achievement: GKAchievement, to percentComplete: Double) { fatalError() }

    @available(*, unavailable)
    open func setAchievementCompleted(_ achievement: GKAchievement) { fatalError() }

    @available(*, unavailable)
    open func progress(on achievement: GKAchievement) -> Double {
        fatalError()
    }

    @available(*, unavailable)
    open func removeAchievements(_ achievements: [GKAchievement]) { fatalError() }

    @available(*, unavailable)
    open func makeMatchRequest() -> GKMatchRequest? {
        fatalError()
    }

    @available(*, unavailable)
    open func findMatch(completionHandler: @escaping @Sendable (GKMatch?, (any Error)?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open func findMatch() async throws -> GKMatch {
        fatalError()
    }

    @available(*, unavailable)
    open func findPlayersForHostedMatch(
        completionHandler: @escaping @Sendable ([GKPlayer]?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func findPlayersForHostedMatch() async throws -> [GKPlayer] {
        fatalError()
    }

    open class func checkPendingGameActivityExistence(completionHandler: @escaping @Sendable (Bool) -> Void) {
        fatalError()
    }

    open class var hasPendingGameActivities: Bool {
        get async {
            fatalError()
        }
    }
}

// MARK: - GKGameSession (GKGameSession.swift header)

public enum GKConnectionState: Int, @unchecked Sendable {
    case notConnected = 0
    case connected = 1
}

public enum GKTransportType: Int, @unchecked Sendable {
    case unreliable = 0
    case reliable = 1
}

public protocol GKGameSessionEventListener: NSObjectProtocol {}

open class GKGameSession: NSObject {
    @available(*, unavailable)
    open var identifier: String { fatalError() }

    @available(*, unavailable)
    open var title: String { fatalError() }

    @available(*, unavailable)
    open var owner: GKCloudPlayer { fatalError() }

    @available(*, unavailable)
    open var players: [GKCloudPlayer] { fatalError() }

    @available(*, unavailable)
    open var lastModifiedDate: Date { fatalError() }

    @available(*, unavailable)
    open var lastModifiedPlayer: GKCloudPlayer { fatalError() }

    @available(*, unavailable)
    open var maxNumberOfConnectedPlayers: Int { fatalError() }

    @available(*, unavailable)
    open var badgedPlayers: [GKCloudPlayer] { fatalError() }

    open class func createSession(
        inContainer containerName: String?,
        withTitle title: String,
        maxConnectedPlayers maxPlayers: Int,
        completionHandler: @escaping @Sendable (GKGameSession?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    open class func createSession(
        inContainer containerName: String?,
        withTitle title: String,
        maxConnectedPlayers maxPlayers: Int
    ) async throws -> GKGameSession {
        fatalError()
    }

    open class func loadSessions(
        inContainer containerName: String?,
        completionHandler: @escaping @Sendable ([GKGameSession]?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    open class func loadSessions(inContainer containerName: String?) async throws -> [GKGameSession] {
        fatalError()
    }

    open class func load(
        withIdentifier identifier: String,
        completionHandler: @escaping @Sendable (GKGameSession?, (any Error)?) -> Void
    ) {
        fatalError()
    }

    open class func load(withIdentifier identifier: String) async throws -> GKGameSession {
        fatalError()
    }

    open class func remove(
        withIdentifier identifier: String,
        completionHandler: @escaping @Sendable ((any Error)?) -> Void
    ) {
        fatalError()
    }

    open class func remove(withIdentifier identifier: String) async throws {
        fatalError()
    }

    @available(*, unavailable)
    open func getShareURL(completionHandler: @escaping @Sendable (URL?, (any Error)?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open func shareURL() async throws -> URL {
        fatalError()
    }

    @available(*, unavailable)
    open func loadData(completionHandler: @escaping @Sendable (Data?, (any Error)?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadData() async throws -> Data {
        fatalError()
    }

    @available(*, unavailable)
    open func save(_ data: Data, completionHandler: @escaping (Data?, (any Error)?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open func setConnectionState(
        _ state: GKConnectionState,
        completionHandler: @escaping @Sendable ((any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func setConnectionState(_ state: GKConnectionState) async throws {
        fatalError()
    }

    @available(*, unavailable)
    open func players(with state: GKConnectionState) -> [GKCloudPlayer] {
        fatalError()
    }

    @available(*, unavailable)
    open func send(
        _ data: Data,
        with transport: GKTransportType,
        completionHandler: @escaping @Sendable ((any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func send(_ data: Data, with transport: GKTransportType) async throws {
        fatalError()
    }

    @available(*, unavailable)
    open func sendMessage(
        withLocalizedFormatKey key: String,
        arguments: [String],
        data: Data?,
        to players: [GKCloudPlayer],
        badgePlayers: Bool,
        completionHandler: @escaping @Sendable ((any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func sendMessage(
        withLocalizedFormatKey key: String,
        arguments: [String],
        data: Data?,
        to players: [GKCloudPlayer],
        badgePlayers: Bool
    ) async throws {
        fatalError()
    }

    @available(*, unavailable)
    open func clearBadge(
        for players: [GKCloudPlayer],
        completionHandler: @escaping @Sendable ((any Error)?) -> Void
    ) {
        fatalError()
    }

    @available(*, unavailable)
    open func clearBadge(for players: [GKCloudPlayer]) async throws {
        fatalError()
    }
}

extension GKGameSession {
    open class func add(listener: any GKGameSessionEventListener) {
        fatalError()
    }

    open class func remove(listener: any GKGameSessionEventListener) {
        fatalError()
    }
}

// MARK: - UIViewController / UINavigationController

#if false
// MARK: - GKGameCenterViewController (GKGameCenterViewController.swift header)

open class GKGameCenterViewController: UINavigationController {
    @available(*, unavailable)
    weak open var gameCenterDelegate: (any GKGameCenterControllerDelegate)?

    @available(*, unavailable)
    public init(state: GKGameCenterViewControllerState) {
        super.init(nibName: nil, bundle: nil)
        fatalError()
    }

    @available(*, unavailable)
    public init(leaderboardID: String, playerScope: GKLeaderboard.PlayerScope, timeScope: GKLeaderboard.TimeScope) {
        super.init(nibName: nil, bundle: nil)
        fatalError()
    }

    @available(*, unavailable)
    public init(leaderboard: GKLeaderboard, playerScope: GKLeaderboard.PlayerScope) {
        super.init(nibName: nil, bundle: nil)
        fatalError()
    }

    @available(*, unavailable)
    public init(leaderboardSetID: String) {
        super.init(nibName: nil, bundle: nil)
        fatalError()
    }

    @available(*, unavailable)
    public init(achievementID: String) {
        super.init(nibName: nil, bundle: nil)
        fatalError()
    }

    @available(*, unavailable)
    public init(player: GKPlayer) {
        super.init(nibName: nil, bundle: nil)
        fatalError()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @available(*, unavailable)
    open var viewState: GKGameCenterViewControllerState {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var leaderboardTimeScope: GKLeaderboard.TimeScope {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var leaderboardIdentifier: String? {
        get { fatalError() }
        set { fatalError() }
    }
}

public protocol GKGameCenterControllerDelegate: NSObjectProtocol {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController)
}

// MARK: - Turn-based UI (GKTurnBasedMatchmakerViewController.swift header)

@available(*, unavailable)
public protocol GKTurnBasedMatchmakerViewControllerDelegate: NSObjectProtocol {
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController)
    func turnBasedMatchmakerViewController(
        _ viewController: GKTurnBasedMatchmakerViewController,
        didFailWithError error: any Error
    )
}

@available(*, unavailable)
open class GKTurnBasedMatchmakerViewController: UINavigationController {
    @available(*, unavailable)
    weak open var turnBasedMatchmakerDelegate: (any GKTurnBasedMatchmakerViewControllerDelegate)? {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var showExistingMatches: Bool {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var matchmakingMode: GKMatchmakingMode {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    public init(matchRequest request: GKMatchRequest) {
        super.init(nibName: nil, bundle: nil)
        fatalError()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - GKFriendRequestComposeViewController (GKFriendRequestComposeViewController.swift header)

@available(*, unavailable)
public protocol GKFriendRequestComposeViewControllerDelegate: AnyObject {
    func friendRequestComposeViewControllerDidFinish(_ viewController: GKFriendRequestComposeViewController)
}

@available(*, unavailable)
open class GKFriendRequestComposeViewController: UINavigationController {
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @available(*, unavailable)
    open class func maxNumberOfRecipients() -> Int { fatalError() }

    @available(*, unavailable)
    open func setMessage(_ message: String?) { fatalError() }

    @available(*, unavailable)
    open func addRecipientPlayers(_ players: [GKPlayer]) { fatalError() }

    @available(*, unavailable)
    public func addRecipients(withPlayerIDs playerIDs: [String]) { fatalError() }

    @available(*, unavailable)
    public func addRecipients(withEmailAddresses emailAddresses: [String]) { fatalError() }

    @available(*, unavailable)
    weak open var composeViewDelegate: (any GKFriendRequestComposeViewControllerDelegate)? {
        get { fatalError() }
        set { fatalError() }
    }
}

// MARK: - GKMatchmakingMode, GKMatchmakerViewController (GKMatchMakerViewController.swift header)

public enum GKMatchmakingMode: Int, @unchecked Sendable {
    case `default` = 0
    case nearbyOnly = 1
    case automatchOnly = 2
    case inviteOnly = 3
}

public protocol GKMatchmakerViewControllerDelegate: NSObjectProtocol {
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController)
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: any Error)
}

open class GKMatchmakerViewController: UINavigationController {
    @available(*, unavailable)
    weak open var matchmakerDelegate: (any GKMatchmakerViewControllerDelegate)? {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var matchRequest: GKMatchRequest { fatalError() }

    @available(*, unavailable)
    open var isHosted: Bool {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var matchmakingMode: GKMatchmakingMode {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var canStartWithMinimumPlayers: Bool {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    public init?(matchRequest request: GKMatchRequest) {
        super.init(nibName: nil, bundle: nil)
        fatalError()
    }

    @available(*, unavailable)
    public init?(invite: GKInvite) {
        super.init(nibName: nil, bundle: nil)
        fatalError()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @available(*, unavailable)
    open func addPlayers(to match: GKMatch) { fatalError() }

    @available(*, unavailable)
    open func setHostedPlayer(_ player: GKPlayer, didConnect connected: Bool) { fatalError() }

    @available(*, unavailable)
    open func setHostedPlayer(_ playerID: String, connected: Bool) { fatalError() }
}

// MARK: - GKLeaderboardViewController, GKLeaderboardSet (GKLeaderboardViewController, GKLeaderboardSet headers)

@available(*, unavailable)
public protocol GKLeaderboardViewControllerDelegate: NSObjectProtocol {
    func leaderboardViewControllerDidFinish(_ leaderboardViewController: GKLeaderboardViewController)
}

@available(*, unavailable)
open class GKLeaderboardViewController: UIViewController {
    @available(*, unavailable)
    open var timeScope: GKLeaderboard.TimeScope {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var category: String! {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    weak open var leaderboardDelegate: (any GKLeaderboardViewControllerDelegate)! {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// UIViewController-based challenge compose typealiases are not bridged in Skip.
@available(*, unavailable)
public typealias GKChallengeComposeCompletionBlock = (UIViewController, Bool, [String]?) -> Void

@available(*, unavailable)
public typealias GKChallengeComposeHandler = (UIViewController, Bool, [GKPlayer]?) -> Void

extension GKLeaderboard.Entry {
    @available(*, unavailable)
    open func challengeComposeController(
        withMessage message: String?,
        players: [GKPlayer]?,
        completionHandler: GKChallengeComposeCompletionBlock?
    ) -> UIViewController {
        fatalError()
    }

    @available(*, unavailable)
    open func challengeComposeController(
        withMessage message: String?,
        players: [GKPlayer]?,
        completion completionHandler: GKChallengeComposeHandler?
    ) -> UIViewController {
        fatalError()
    }
}

#endif

#endif

#endif

