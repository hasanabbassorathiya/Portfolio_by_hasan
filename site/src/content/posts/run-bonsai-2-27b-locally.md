Every few months a model lands that makes "run it locally" stop being a joke. Bonsai 2 is one of them. Prism ML released a ternary-quantized 27.8B model that fits in roughly 6 GB, which means a recent laptop — not a server, not a cloud bill — can drive a model in the same weight class as the ones you pay an API for.

I build mobile and AI products for a living, and the question I keep getting is "can we run this on-device, or at least on a machine we control?" This post is the concrete answer for Bonsai 2: which file to download, the one gotcha that makes most setups fail, and the commands that actually run it.

## What Bonsai 2 actually is

Per [Prism ML's launch note](https://prismml.com/news/prismml-launches-bonsai-2-27b) and the [model card](https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-gguf), the facts worth knowing:

- It is a 27.8B-parameter multimodal model derived from Qwen3.8-27B, with a hybrid attention architecture.
- The trick is ternary quantization — weights stored at roughly 1.75 to 2.25 bits instead of 16. Prism ML reports an aggregate benchmark score of 83.9, retaining about 98.2% of the base model's performance. Those are their numbers, not mine; treat them as a claim to verify on your own tasks.
- Context length is inherited from the base model: 262K tokens, though what you can actually use depends on your hardware.
- License is Apache 2.0, so commercial use is fine.

The headline is the size-to-capability ratio. A dense 27B at FP16 is around 54 GB and does not fit on a laptop. The ternary build is under 6 GB.

## Pick the right quant (this is the gotcha)

The model card ships several variants, and they are not interchangeable:

| Variant | Size | Runs on |
|---------|------|---------|
| PTQ1_0 | 5.95 GB | Prism ML's llama.cpp fork only |
| PQ2_0 | 7.21 GB | Prism ML's llama.cpp fork only |
| Q2_0 | 7.63 GB | Stock llama.cpp b11556 or newer |
| F16 | 53.8 GB | Full precision, not for laptops |

Here is the part that burns people: the smallest files (PTQ1_0 and PQ2_0) use ternary kernels that **stock llama.cpp will reject as an unknown type**. If you grab the 5.95 GB file and run it with a normal build, it will not load. You have two clean paths:

1. Use the Prism ML fork for the smallest, fastest quants.
2. Use the Q2_0 file with a recent stock llama.cpp (b11556+, which added the needed activation support). Older stock builds produce garbage output, so do not skip the version check.

If you just want it working with the least friction, Q2_0 on a current stock build is the safe choice. If you want the smallest footprint, use the fork.

## Path A: the Prism ML fork (smallest footprint)

Build the fork with the ternary kernels. On macOS, Metal is the default, so drop the CUDA flag:

```bash
git clone https://github.com/PrismML-Eng/llama.cpp && cd llama.cpp
cmake -B build -DGGML_CUDA=ON && cmake --build build -j
# on macOS: cmake -B build && cmake --build build -j
```

Download the quant you want, then run it:

```bash
hf download prism-ml/Ternary-Bonsai-2-27B-gguf Ternary-Bonsai-2-27B-PQ2_0.gguf --local-dir .

./bin/llama-cli -m Ternary-Bonsai-2-27B-PQ2_0.gguf \
    -ngl 99 -fa on -c 32768 \
    --temp 1.0 --top-p 0.95 --top-k 20 --min-p 0.05 \
    -p "Explain quantum computing in simple terms." -n 16384
```

The flags that matter: `-ngl 99` offloads every layer to the GPU, `-fa on` enables flash attention, `-c 32768` sets a 32K context (raise it if you have the memory), and `-n 16384` leaves room for the model's thinking traces. The model card recommends `--min-p 0.05` for better instruction following.

## Path B: stock llama.cpp (least friction)

If you would rather not build a fork, take the Q2_0 file and a current stock build:

```bash
hf download prism-ml/Ternary-Bonsai-2-27B-gguf Ternary-Bonsai-2-27B-Q2_0.gguf --local-dir .

llama-cli -m Ternary-Bonsai-2-27B-Q2_0.gguf \
    -ngl 99 -fa on -c 32768 \
    --temp 1.0 --top-p 0.95 --top-k 20 --min-p 0.05 \
    -p "Summarize the trade-offs of ternary quantization." -n 16384
```

## Path C: Ollama or LM Studio

If you live in a GUI, both can pull it straight from Hugging Face:

```bash
ollama run hf.co/prism-ml/Ternary-Bonsai-2-27B-gguf:F16
```

LM Studio uses the protocol link `lmstudio://open_from_hf?model=prism-ml/Ternary-Bonsai-2-27B-gguf`. Note the Ollama example pulls F16, which is the 54 GB file — fine on a big machine, but pick a smaller quant if you are on a laptop.

## What to expect on real hardware

The model card lists roughly 130 tokens/second on an RTX 5090, about 28 on an Apple M5 Pro and 47 on an M5 Max, and around 30 on an L4. Prism ML's launch note quotes up to 143 tokens/second on the 5090. Again, these are reported figures — your throughput will depend on quant, context length, and how much fits in memory. The practical floor is about 6 GB of RAM or VRAM to load the smallest build.

If you want image input, there is an optional Q8_0 vision tower (a 0.63 GB mmproj file) that you load only when you need it.

## Why this matters for the work I do

The reason I care about a model like this is not the benchmark. It is the deployment shape. A 27B-class model that runs on hardware you control changes three things: latency stops being a network round-trip, sensitive data never leaves the device, and the marginal cost of a query goes to zero. For a mobile product, that is the difference between "AI feature we rent" and "AI feature we own."

Ternary quantization is the technique to watch. If a 9x size reduction really holds ~98% of quality across tasks, the on-device ceiling moves a lot. Verify it on your own workload before you bet a feature on it — but the direction is unmistakable.

If you are weighing on-device versus API for a product and want a second opinion on the trade-offs, [send me the details](mailto:hasanabbassorathiya12@gmail.com?subject=Local%20LLM). I have shipped enough of both to know where each one breaks.