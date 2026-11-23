/**
 * A lock held by a live process, or by one `ps` cannot tell running or gone, is
 * waited on until `options.until` passes, and the call then fails naming the
 * holder. A lock naming a process that has gone is taken over.
 */
export function holdingLock<T>(directory: string, name: string, act: () => T, options: UpdateOptions): Locked<T> {
  const { until } = options;
  const notHeld = (reason: string): Locked<T> => ({ outcome: "failed", reason });
  const boundMs = (): number => Math.max(1, until.remaining());

  // Runs `ps` for this process's own start time.
  const self = options.self ?? ownIdentity(boundMs(), options.identify);
  if ("reason" in self) return notHeld(self.reason);

  for (;;) {
    // Runs `ps` once for each holder it finds named in the lock.
    const taking = takeLock(directory, name, { boundMs: boundMs(), self, presence: stillRunning });
    if (taking.outcome === "taken") {
      if (!until.passed()) return { outcome: "held", value: runHolding(act, taking.lock) };
      // The caller's time for this write has gone, so the lock goes back unused.
      taking.lock.release();
      return notHeld("its lock was taken only after the deadline had passed");
    }
    if (until.passed()) return notHeld(whyNotTaken(taking));
    pause(Math.min(until.remaining(), PAUSE_MS));
  }
}
