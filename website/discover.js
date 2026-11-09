const API = "https://api.tenrai.org/v1";
const grid = document.querySelector("#anime-grid");
const statusBox = document.querySelector("#status");
const form = document.querySelector("#search-form");
const input = document.querySelector("#search-input");
const typeFilter = document.querySelector("#type-filter");
const heading = document.querySelector("#catalog-heading");
const subheading = document.querySelector("#catalog-sub");
const prev = document.querySelector("#prev-page");
const next = document.querySelector("#next-page");
const pageLabel = document.querySelector("#page-label");

let query = "";
let page = 1;
let requestController = null;
let requestNumber = 0;
let lastRequestAt = 0;

function escapeHTML(value = "") {
  return String(value).replace(/[&<>"']/g, char => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;"
  }[char]));
}

function scoreLabel(score) {
  return typeof score === "number" && score > 0 ? score.toFixed(2) : "N/A";
}

function card(anime) {
  const image = anime.images?.jpg?.large_image_url || anime.images?.jpg?.image_url || "";
  const title = anime.title_english || anime.title || "Untitled";
  const year = anime.year || (anime.aired?.from ? new Date(anime.aired.from).getFullYear() : "—");
  return `<a class="anime-card" href="anime.html?id=${encodeURIComponent(anime.mal_id)}">
    <div class="poster-wrap">
      ${image
        ? `<img src="${escapeHTML(image)}" alt="${escapeHTML(title)} poster" loading="lazy">`
        : '<div class="poster-fallback">ANIWATCH</div>'}
      <span class="rating-pill">★ ${scoreLabel(anime.score)}</span>
      <span class="poster-type">${escapeHTML(anime.type || "Anime")}</span>
    </div>
    <div class="anime-card-info">
      <h3>${escapeHTML(title)}</h3>
      <p>${escapeHTML(year)} <span>·</span> ${escapeHTML(anime.episodes ?? "—")} eps</p>
    </div>
  </a>`;
}

function setStatus(message, visible = true) {
  statusBox.textContent = message;
  statusBox.hidden = !visible;
}

function wait(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function fetchWithTimeout(url, signal, timeoutMs = 15000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);
  const abortFromCaller = () => controller.abort();
  signal.addEventListener("abort", abortFromCaller, { once: true });

  try {
    const response = await fetch(url, { signal: controller.signal });
    return response;
  } catch (error) {
    if (signal.aborted) throw new DOMException("Request cancelled", "AbortError");
    if (controller.signal.aborted) {
      throw new Error("The anime API took too long to respond. Check your connection and try again.");
    }
    throw new Error("Unable to reach the anime API. Check your internet connection or try again later.");
  } finally {
    clearTimeout(timeoutId);
    signal.removeEventListener("abort", abortFromCaller);
  }
}

async function requestAnime(url, signal) {
  // Tenrai is a public API with rate limits. Space out requests.
  const waitTime = Math.max(0, 1100 - (Date.now() - lastRequestAt));
  if (waitTime) await wait(waitTime);
  if (signal.aborted) throw new DOMException("Request cancelled", "AbortError");

  lastRequestAt = Date.now();
  let response = await fetchWithTimeout(url, signal);

  // Retry a rate-limited request once after a cooldown.
  if (response.status === 429) {
    await wait(3000);
    if (signal.aborted) throw new DOMException("Request cancelled", "AbortError");
    lastRequestAt = Date.now();
    response = await fetchWithTimeout(url, signal);
  }

  if (!response.ok) {
    if (response.status === 429) {
      throw new Error("Tenrai is temporarily rate-limiting requests. Wait a few seconds and try again.");
    }
    throw new Error(`Anime API returned an error (${response.status}). Please try again.`);
  }
  try {
    return await response.json();
  } catch {
    throw new Error("The anime API returned an invalid response. Please try again.");
  }
}

async function loadAnime() {
  const currentRequest = ++requestNumber;
  if (requestController) requestController.abort();
  requestController = new AbortController();
  const { signal } = requestController;

  grid.innerHTML = "";
  setStatus(query ? "Searching anime…" : "Loading popular anime…");
  heading.textContent = query ? "Search results" : (typeFilter.value ? "Browse anime" : "Popular anime");
  subheading.textContent = query
    ? `Results for “${query}”`
    : "Top-rated picks from MyAnimeList";
  prev.disabled = true;
  next.disabled = true;

  const params = new URLSearchParams({
    page: String(page),
    limit: "24",
    sfw: "true"
  });

  let endpoint;
  if (query || typeFilter.value) {
    endpoint = "anime";
    if (query) params.set("q", query);
    if (typeFilter.value) params.set("type", typeFilter.value);
    if (!query) {
      params.set("order_by", "score");
      params.set("sort", "desc");
    }
  } else {
    endpoint = "top/anime";
  }

  try {
    const payload = await requestAnime(`${API}/${endpoint}?${params.toString()}`, signal);
    if (currentRequest !== requestNumber) return;

    const results = Array.isArray(payload.data) ? payload.data : [];
    if (!results.length) {
      setStatus("No anime found. Try a different title.");
      pageLabel.textContent = `Page ${page}`;
      return;
    }

    grid.innerHTML = results.map(card).join("");
    setStatus("", false);

    const pagination = payload.pagination || {};
    pageLabel.textContent = `Page ${pagination.current_page || page}`;
    prev.disabled = page <= 1;
    next.disabled = !pagination.has_next_page;
  } catch (error) {
    if (error.name === "AbortError" || currentRequest !== requestNumber) return;
    setStatus(error.message || "Could not load anime. Check your internet connection and try again.");
    pageLabel.textContent = `Page ${page}`;
  }
}

form.addEventListener("submit", event => {
  event.preventDefault();
  if (requestController) requestController.abort();
  query = input.value.trim();
  page = 1;
  loadAnime();
});

typeFilter.addEventListener("change", () => {
  page = 1;
  loadAnime();
});

prev.addEventListener("click", () => {
  if (page > 1) {
    page--;
    loadAnime();
    window.scrollTo({ top: 0, behavior: "smooth" });
  }
});

next.addEventListener("click", () => {
  page++;
  loadAnime();
  window.scrollTo({ top: 0, behavior: "smooth" });
});

loadAnime();