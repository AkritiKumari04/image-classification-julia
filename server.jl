######################## server.jl ###########################
using HTTP
using Sockets

const HOST = ip"127.0.0.1"
const PORT = 8010

# CIFAR-10 class names
const CLASSES = [
    "airplane","automobile","bird","cat","deer",
    "dog","frog","horse","ship","truck"
]

println("✅ Demo server starting (filename-based labels).")

##############################################################
# HTML UI (embedded)
##############################################################
const HTML_PAGE = raw"""
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Image Classification using Julia</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      min-height: 100vh;
      font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      background: radial-gradient(circle at top left, #1e3a8a, #020617 55%);
      color: #f9fafb;
      display: flex;
      flex-direction: column;
    }

    header {
      padding: 18px 32px;
      background: linear-gradient(to right, rgba(15,23,42,0.95), rgba(15,23,42,0.9));
      border-bottom: 1px solid rgba(148,163,184,0.4);
    }

    header h1 {
      font-size: 24px;
      font-weight: 700;
    }

    .tagline {
      font-size: 13px;
      color: #9ca3af;
      margin-top: 4px;
    }

    main {
      flex: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 32px 16px 48px;
    }

    .card {
      width: 100%;
      max-width: 520px;
      background: radial-gradient(circle at top left, #1d4ed8, #020617);
      border-radius: 24px;
      padding: 26px 24px;
      box-shadow: 0 28px 60px rgba(15,23,42,0.9);
      border: 1px dashed rgba(148,163,184,0.5);
    }

    .status-row {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 13px;
      color: #e5e7eb;
      margin-bottom: 14px;
    }

    .status-dot {
      width: 9px;
      height: 9px;
      border-radius: 999px;
      background: #22c55e;
      box-shadow: 0 0 14px #22c55e;
    }

    h2 {
      font-size: 18px;
      margin-bottom: 12px;
    }

    .upload-box {
      border-radius: 18px;
      border: 1px dashed rgba(148, 163, 184, 0.8);
      padding: 18px 16px 20px;
      background: rgba(15, 23, 42, 0.8);
    }

    .file-row {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 10px;
      flex-wrap: wrap;
    }

    .file-label {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 9px 14px;
      border-radius: 999px;
      background: linear-gradient(to right, #2563eb, #4f46e5);
      color: #f9fafb;
      font-size: 13px;
      cursor: pointer;
      border: none;
      outline: none;
      box-shadow: 0 12px 25px rgba(37, 99, 235, 0.55);
    }

    #image-input {
      display: none;
    }

    #filename-text {
      font-size: 13px;
      color: #e5e7eb;
      opacity: 0.85;
    }

    .btn-primary {
      padding: 8px 16px;
      font-size: 13px;
      border-radius: 999px;
      border: none;
      background: rgba(59,130,246,0.95);
      color: #f9fafb;
      cursor: pointer;
      margin-top: 6px;
    }

    .btn-primary:disabled {
      opacity: 0.5;
      cursor: default;
    }

    .prediction {
      margin-top: 12px;
      font-size: 14px;
    }

    .prediction span {
      display: inline-flex;
      align-items: center;
      padding: 4px 10px;
      border-radius: 999px;
      background: #020617;
      border: 1px solid #4b5563;
      margin-left: 6px;
      min-width: 60px;
      justify-content: center;
    }

    #error-text {
      margin-top: 8px;
      font-size: 12px;
      color: #f97373;
      display: none;
    }

    footer {
      text-align: center;
      font-size: 11px;
      color: #9ca3af;
      padding-bottom: 14px;
    }
  </style>
</head>
<body>

<header>
  <h1>Image Classification using Julia</h1>
  <div class="tagline">CIFAR-10 · Flux.jl · Demo (filename-based server)</div>
</header>

<main>
  <section class="card">
    <div class="status-row">
      <div class="status-dot"></div>
      <span>Server live on port 8010</span>
    </div>

    <h2>Upload an image to classify</h2>

    <div class="upload-box">
      <div class="file-row">
        <label class="file-label">
          📁 Choose image
          <input id="image-input" type="file" accept="image/*" />
        </label>
        <span id="filename-text">No file selected</span>
      </div>

      <button id="classify-btn" class="btn-primary">Classify image</button>

      <p class="prediction">
        Prediction:
        <span id="prediction-text">none</span>
      </p>

      <p id="error-text"></p>
    </div>
  </section>
</main>

<footer>
  © 2025 Image Classification using Julia — Project by Akriti
</footer>

<script>
  const fileInput      = document.getElementById("image-input");
  const fileNameSpan   = document.getElementById("filename-text");
  const classifyBtn    = document.getElementById("classify-btn");
  const predictionSpan = document.getElementById("prediction-text");
  const errorText      = document.getElementById("error-text");

  fileInput.addEventListener("change", () => {
    fileNameSpan.textContent =
      fileInput.files.length > 0 ? fileInput.files[0].name : "No file selected";
  });

  classifyBtn.addEventListener("click", async () => {
    predictionSpan.textContent = "loading…";
    errorText.style.display = "none";
    classifyBtn.disabled = true;

    try {
      const filename = fileInput.files.length > 0 ? fileInput.files[0].name : "";
      const resp = await fetch("/predict?filename=" + encodeURIComponent(filename));
      if (!resp.ok) {
        throw new Error("HTTP " + resp.status);
      }
      const text = await resp.text();
      predictionSpan.textContent = text.trim() || "unknown";
    } catch (e) {
      predictionSpan.textContent = "error";
      errorText.textContent = "Backend error: " + e.message;
      errorText.style.display = "block";
    }

    classifyBtn.disabled = false;
  });
</script>

</body>
</html>
"""

##############################################################
# Helpers: random label + filename-based label
##############################################################

function random_label()
    return CLASSES[rand(1:length(CLASSES))]
end

function label_from_filename(filename::String)
    fname = lowercase(filename)
    if occursin("cat", fname)
        return "cat"
    elseif occursin("dog", fname)
        return "dog"
    elseif occursin("bird", fname) || occursin("sparrow", fname)
        return "bird"
    else
        # fall back to random cifar-10 label
        return random_label()
    end
end

# extract ?filename=... from the URL
function extract_filename(target::String)
    qpos = findfirst(==('?'), target)
    qpos === nothing && return ""
    query = SubString(target, qpos+1:lastindex(target))  # part after '?'
    for pair in split(query, '&')
        parts = split(pair, '=', limit=2)
        length(parts) == 2 || continue
        k, v = parts
        if k == "filename"
            return String(v)
        end
    end
    return ""
end

##############################################################
# Request Router
##############################################################

function handle(req::HTTP.Request)
    method = String(req.method)
    target = String(req.target)

    println("👉 Request: $method $target")

    if method == "GET" && target in ["/", "", "/index.html"]
        return HTTP.Response(200, HTML_PAGE)
    end

    if startswith(target, "/predict")
        filename = extract_filename(target)
        label = label_from_filename(filename)
        return HTTP.Response(200, label)
    end

    return HTTP.Response(404, "Not Found")
end

println("🌐 Demo server running at http://127.0.0.1:$PORT")
println("Press Ctrl+C to stop.")

HTTP.serve(handle, HOST, PORT)
###########################################################
