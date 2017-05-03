//
//  DispatchOnce.swift
//  Wager
//
//  Created by Tyler Kaye on 5/2/17.
//
//

import Foundation

public final class /* struct */ DispatchOnce {
  private var lock: OSSpinLock = OS_SPINLOCK_INIT
  private var isInitialized = false
  public /* mutating */ func perform(block: (Void) -> Void) {
    OSSpinLockLock(&lock)
    if !isInitialized {
      block()
      isInitialized = true
    }
    OSSpinLockUnlock(&lock)
  }
}
