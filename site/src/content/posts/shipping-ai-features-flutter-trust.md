AI features fail in mobile apps for a reason that has little to do with model quality: they make users wait, and they are confidently wrong. Both erode trust faster than a missing feature ever would. Here is how I ship AI inside Flutter apps without asking users to believe in magic.

## Latency is the feature

A chat response that takes nine seconds is not a nine-second feature. It is a nine-second decision about whether to close the app. Before writing any prompt, I write a latency budget:

- **First token visible:** under 1.2 seconds on a good connection.
- **Useful partial answer:** under 3 seconds.
- **Full answer:** under 8 seconds, with a visible way to stop.
- **Offline:** a clear, useful fallback — never a spinner that never ends.

If the backend cannot meet the first-token budget, the feature is not ready, regardless of how good the answer is. Streaming is not a nice-to-have; it is how you turn waiting into progress.

## Stream everything the user can read

On the Flutter side, treat the response as a stream and render tokens as they arrive:

```dart
final response = ref.watch(answerProvider); // AsyncValue<String>

return response.when(
  loading: () => const AnswerSkeleton(),
  error: (e, _) => AnswerError(
    message: 'I could not reach the assistant.',
    onRetry: () => ref.invalidate(answerProvider),
  ),
  data: (text) => SelectableText(text),
);
```

The server should emit SSE tokens, not wait for a complete completion. Users tolerate a slow answer they can watch being written far better than a fast-looking spinner that lies about progress.

## Show your work

In a religious-content app, a wrong answer is not a bad user experience — it is a trust incident. Every generated answer that references content must link back to the source passage, and the UI must make the distinction between **quoted content** and **generated explanation** obvious.

The pattern I use:

1. Retrieve passages first.
2. Generate an answer constrained to those passages.
3. Return citations alongside the text.
4. Render citations as tappable chips that open the original content.

If retrieval returns nothing relevant, the assistant says so. "I could not find this in the library" is a much better answer than a plausible invention.

## Version prompts like code

A prompt is a production artifact. It gets a version, a changelog, and a test set:

```text
prompts/
  assistant/
    v3.md
    v3.eval.jsonl
    CHANGELOG.md
```

The eval set is 30 to 50 real questions users have actually asked, each with an expected behavior — not an exact string. I score three things: correct source retrieved, answer grounded in the source, and refusal when the source is missing. A prompt change ships only if those scores hold.

This is unglamorous, and it is the difference between an AI feature you can maintain and one you are afraid to touch.

## Design the failure states first

Models time out. Providers rate-limit. JSON comes back malformed. The UI needs a deliberate answer for each:

- **Timeout:** show the last good answer with a retry, not an empty screen.
- **Rate limit:** explain the wait in human terms and offer a non-AI path.
- **Low confidence:** fall back to search or a curated list.
- **Offline:** queue the request or disable the input with a clear reason.

I sketch these states before the happy path. It changes the architecture: the assistant becomes one route among several, not a single point of failure.

## Privacy is a product decision

Mobile users deserve to know what leaves the device. My rules:

- Never send identifiers, contact lists, or precise location to a model unless the feature genuinely requires it.
- Redact personal data before it reaches the provider.
- Keep a local history the user can delete.
- Say, in plain language, what is stored and for how long.

For a community app, this matters more than a clever prompt. People talk to an app about things they would not post publicly. Treat that accordingly.

## Human confirmation for actions

Anything that changes state — sending a message, booking a slot, making a payment — needs an explicit confirmation step that shows exactly what will happen. The model proposes; the user approves. This is not a limitation to apologize for. It is the reason people will trust the feature with real tasks.

## Cost guardrails from day one

AI features have a variable cost per user, which is unusual for mobile teams. I add:

- A per-user daily request cap with a friendly message.
- Server-side token limits for input and output.
- Caching for repeated questions.
- A cheap model for classification and routing, an expensive one only for final answers.

Without caps, one power user with a script can cost more than a hundred normal users. The cap is not anti-user; it protects the feature for everyone.

## What "done" looks like

An AI feature is done when:

1. It streams and can be cancelled.
2. Every claim that needs a source has one.
3. The failure states are designed, not accidental.
4. There is an eval set and a prompt changelog.
5. A user can delete their data.
6. Costs are capped and measured.

None of that is about the model. All of it is about trust. That is the actual product.

If you are adding AI to a mobile product and want a second opinion on the architecture, [let's talk](mailto:hasanabbassorathiya12@gmail.com). I have shipped this pattern in consumer and enterprise apps, including offline-first religious content where being wrong is not an option.
