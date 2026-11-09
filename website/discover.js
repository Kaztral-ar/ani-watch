const API = "https://api.jikan.moe/v4";
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
let lastRequest = 0;
let debounceTimer;

function escapeHTML(value = "") {
  return String(value).replace(/[&<>"']/g, char => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[char]));
}
function scoreLabel(score) {
  return typeof score === "number" && score > 0 ? score.toFixed(2) : "N/A";
}
function card(anime) {
  const image = anime.images?.jpg?.large_image_url || anime.images?.jpg?.image_url || "";
  const title = anime.title_english || anime.title || "Untitled";
  const year = anime.year || (anime.aired?.from ? new Date(anime.aired.from).getFullYear() : "—");
  const score = scoreLabel(anime.score);
  return `<a class="anime-card" href="anime.html?id=${encodeURIComponent(anime.mal_id)}">
    <div class="poster-wrap">${image ? `<img src="${escapeHTML(image)}" alt="${escapeHTML(title)} poster" loading="lazy">` : '<div class="poster-fallback">ANIWATCH</div>'}
      <span class="rating-pill">★ ${score}</span><span class="poster-type">${escapeHTML(anime.type || "Anime")}</span></div>
    <div class="anime-card-info"><h3>${escapeHTML(title)}</h3><p>${escapeHTML(year)} <span>·</span> ${escapeHTML(anime.episodes ?? "—")} eps</p></div></a>`;
}
function setStatus(message, visible = true) { statusBox.textContent = message; statusBox.hidden = !visible; }
async function loadAnime() {
  const requestId = ++lastRequest;
  grid.innerHTML = "";
  setStatus(query ? "Searching anime…" : "Loading popular anime…");
  heading.textContent = query ? "Search results" : "Popular anime";
  subheading.textContent = query ? `Results for “${query}”` : "Top-rated picks from MyAnimeList";
  const params = new URLSearchParams({page: String(page), limit: "24", sfw: "true"});
  if (query) params.set("q", query);
  if (typeFilter.value) params.set("type", typeFilter.value);
  else if (!query) params.set("order_by", "score");
  try {
    const response = await fetch(`${API}/${query || typeFilter.value ? "anime" : "top/anime"}?${params}`);
    if (!response.ok) throw new Error(response.status === 429 ? "The anime API is receiving too many requests. Please wait a moment and try again." : `Anime API error (${response.status}).`);
    const payload = await response.json();
    if (requestId !== lastRequest) return;
    const results = payload.data || [];
    if (!results.length) { setStatus("No anime found. Try another title."); return; }
    setStatus("", false);
    grid.innerHTML = results.map(card).join("");
    const pagination = payload.pagination || {};
    const current = pagination.current_page || page;
    const hasNext = Boolean(pagination.has_next_page);
    pageLabel.textContent = `Page ${current}`;
    prev.disabled = page <= 1;
    next.disabled = !hasNext;
  } catch (error) {
    if (requestId !== lastRequest) return;
    setStatus(error.message || "Could not load anime. Check your connection and try again.");
    prev.disabled = page <= 1;
    next.disabled = true;
  }
}
form.addEventListener("submit", event => {
  event.preventDefault();
  query = input.value.trim();
  page = 1;
  loadAnime();
});
input.addEventListener("input", () => {
  clearTimeout(debounceTimer);
  debounceTimer = setTimeout(() => {
    query = input.value.trim();
    page = 1;
    loadAnime();
  }, 550);
});
typeFilter.addEventListener("change", () => { page = 1; loadAnime(); });
prev.addEventListener("click", () => { if (page > 1) { page--; loadAnime(); window.scrollTo({top: 0, behavior: "smooth"}); } });
next.addEventListener("click", () => { page++; loadAnime(); window.scrollTo({top: 0, behavior: "smooth"}); });
loadAnime();