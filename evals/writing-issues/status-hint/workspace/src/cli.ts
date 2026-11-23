export async function main(argv: string[]): Promise<number> {
  const command = argv[0];
  if (command === "review") {
    return review(argv.slice(1));
  }
  if (command === "threads") {
    return listThreads();
  }
  if (command === "reply") {
    return postReply(argv.slice(1));
  }
  if (command === "status") {
    const chosen = venueAt(process.cwd());
    if (chosen.outcome === "failed") {
      reportFailure(`no reviews listed: ${chosen.reason}`);
      return 0;
    }
    const printed = squizStatus(process.cwd(), chosen.venue);
    process.stdout.write(printed.stdout);
    process.stderr.write(printed.stderr);
    return 0;
  }
  return usage();
}
