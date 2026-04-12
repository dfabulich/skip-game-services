// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
#if SKIP
import Foundation

open class GKBasePlayer: NSObject/*, NSCopying */ {

    @available(*, unavailable)
    open var playerID: String? { get { fatalError() } }
}

#endif
#endif
