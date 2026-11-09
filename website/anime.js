const API = "https://api.jikan.moe/v4";
const params = new URLSearchParams(location.search);
const id = params.get("id");
const statusBox = document.querySelector("#detail-status");
const detail = document.querySelector("#anime-detail");
function escapeHTML(value = "") {
  return String(value).replace(/[&<>"']/g, char => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[char]));
}
function list(items) { return (items || []).map(item => item.name).filter(Boolean).join(", ") || "Not available"; }
function date(value) {
  if (!value) return "Not announced";
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? value : parsed.toLocaleDateString(undefined, {year:"numeric",month:"long",day:"numeric"});
}
async function loadDetails() {
  if (!id || !/^\d+$/.test(id)) { statusBox.textContent = "No valid anime ID was provided."; return; }
  try {
    const response = await fetch(`${API}/anime/${encodeURIComponent(id)}/full`);
    if (!response.ok) throw new Error(response.status === 429 ? "Too many API requests. Please wait and retry." : `Could not load anime details (${response.status}).`);
    const payload = await response.json();
    const anime = payload.data;
    if (!anime) throw new Error("Anime details were not found.");
    const title = anime.title_english || anime.title || "Anime details";
    document.title = `${title} — AniWatch`;
    const image = anime.images?.jpg?.large_image_url || anime.images?.jpg?.image_url || "";
    const genres = [...(anime.genres || []), ...(anime.themes || [])].map(item => item.name);
    const studios = list(anime.studios);
    const producers = list(anime.producers);
    const score = typeof anime.score === "number" && anime.score > 0 ? anime.score.toFixed(2) : "N/A";
    statusBox.hidden = true;
    detail.innerHTML = `<section class="detail-hero">
      <div class="detail-poster">${image ? `<img src="${escapeHTML(image)}" alt="${escapeHTML(title)} poster">` : '<div class="poster-fallback">ANIWATCH</div>'}</div>
      <div class="detail-content"><div class="section-kicker">MYANIMELIST DATABASE</div><h1>${escapeHTML(title)}</h1>
      ${anime.title_japanese ? `<p class="japanese-title">${escapeHTML(anime.title_japanese)}</p>` : ""}
      <div class="detail-badges"><span>★ ${score} / 10</span><span>${escapeHTML(anime.type || "Anime")}</span><span>${escapeHTML(anime.status || "Status unknown")}</span></div>
      <p class="detail-synopsis">${escapeHTML(anime.synopsis || "No synopsis is available for this title.")}</p>
      <div class="genre-list">${genres.map(name => `<span>${escapeHTML(name)}</span>`).join("")}</div>
      <a class="button button-ghost external-link" href="${escapeHTML(anime.url || "#")}" target="_blank" rel="noreferrer">View on MyAnimeList ↗</a>
      </div></section>
      <section class="detail-facts"><div><span>Episodes</span><strong>${escapeHTML(anime.episodes ?? "Unknown")}</strong></div><div><span>Year</span><strong>${escapeHTML(anime.year || "Unknown")}</strong></div><div><span>Season</span><strong>${escapeHTML(anime.season ? anime.season[0].toUpperCase() + anime.season.slice(1) : "—")}</strong></div><div><span>Duration</span><strong>${escapeHTML(anime.duration || "—")}</strong></div><div><span>Rank</span><strong>${anime.rank ? "#" + escapeHTML(anime.rank) : "—"}</strong></div><div><span>Popularity</span><strong>${anime.popularity ? "#" + escapeHTML(anime.popularity) : "—"}</strong></div><div><span>Aired</span><strong>${escapeHTML(date(anime.aired?.from))}</strong></div><div><span>Source</span><strong>${escapeHTML(anime.source || "—")}</strong></div><div><span>Studios</span><strong>${escapeHTML(studios)}</strong></div><div><span>Producers</span><strong>${escapeHTML(producers)}</strong></div></section>
      <p class="rating-note">The score shown is the MyAnimeList community rating delivered by Jikan. It is not an AniWatch rating.</p>`;
  } catch (error) { statusBox.textContent = error.message || "Something went wrong."; }
}
loadDetails();