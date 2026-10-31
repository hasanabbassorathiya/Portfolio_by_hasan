import { useSyncExternalStore } from 'react';
import { apps as seedApps } from '../content/apps';
import { clients as seedClients } from '../content/clients';
import { posts as seedPosts } from '../content/posts';
import { experiences as seedExperiences, skillGroups as seedSkills } from '../content/experience';
import { profile as seedProfile } from '../content/profile';
import {
  groupSkills,
  mapApps,
  mapClients,
  mapExperiences,
  mapPosts,
  mapProfile,
} from './content-mappers';

const API = '/api/index.php';
const TIMEOUT = 5000;

const state = {
  apps: seedApps,
  clients: seedClients,
  posts: seedPosts,
  experiences: seedExperiences,
  skills: seedSkills,
  profile: seedProfile,
  live: false,
  started: false,
};
const listeners = new Set();

function emit() {
  listeners.forEach((listener) => listener());
}

function subscribe(listener) {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

const isFilled = (value) => typeof value === 'string' && value.trim() !== '';

function validSlugged(titleKey) {
  return (row) =>
    row && typeof row === 'object' && !Array.isArray(row) &&
    isFilled(row.slug) && isFilled(row[titleKey]);
}

const validators = {
  apps: validSlugged('name'),
  clients: validSlugged('name'),
  posts: validSlugged('title'),
  experience: (row) =>
    row && isFilled(row.company) && isFilled(row.position) && isFilled(row.period),
  skills: (row) => row && isFilled(row.grp) && isFilled(row.name),
  profile: (row) => row && isFilled(row.k) && typeof row.v === 'string',
};

async function fetchEntity(entity, signal) {
  const res = await fetch(`${API}?entity=${entity}`, {
    signal,
    headers: { Accept: 'application/json' },
  });
  if (!res.ok) throw new Error(`${entity}: ${res.status}`);
  const payload = await res.json();
  if (!Array.isArray(payload?.data) || !payload.data.every(validators[entity])) {
    throw new Error(`${entity}: malformed response`);
  }
  return payload.data;
}

// Catalogue tables drive visibility: an empty response clears the section.
// Experience, skills and profile keep seeds until real rows exist, because an
// unseeded table must not blank the resume or the hero.
async function hydrate(entity, signal, apply, keepSeedOnEmpty = false) {
  const rows = await fetchEntity(entity, signal);
  if (keepSeedOnEmpty && rows.length === 0) return false;
  apply(rows);
  return true;
}

export function loadLiveContent() {
  if (state.started || typeof window === 'undefined') return;
  state.started = true;

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), TIMEOUT);

  Promise.allSettled([
    hydrate('apps', controller.signal, (value) => { state.apps = mapApps(value, seedApps); }),
    hydrate('clients', controller.signal, (value) => { state.clients = mapClients(value, seedClients); }),
    hydrate('posts', controller.signal, (value) => { state.posts = mapPosts(value, seedPosts); }),
    hydrate('experience', controller.signal, (value) => { state.experiences = mapExperiences(value); }, true),
    hydrate('skills', controller.signal, (value) => { state.skills = groupSkills(value); }, true),
    hydrate('profile', controller.signal, (value) => {
      const mapped = mapProfile(value);
      // The retired aggregate token stays out of production until the CMS row is migrated.
      if (typeof mapped.sub === 'string' && mapped.sub.includes('{{users}}')) delete mapped.sub;
      state.profile = { ...seedProfile, ...mapped };
    }, true),
  ]).then((results) => {
    clearTimeout(timer);
    state.live = results.some((result) => result.status === 'fulfilled' && result.value === true);
    emit();
  });
}

const snapshot = {
  apps: () => state.apps,
  clients: () => state.clients,
  posts: () => state.posts,
  experiences: () => state.experiences,
  skills: () => state.skills,
  profile: () => state.profile,
};

export function useApps() {
  return useSyncExternalStore(subscribe, snapshot.apps, snapshot.apps);
}

export function useClients() {
  return useSyncExternalStore(subscribe, snapshot.clients, snapshot.clients);
}

export function usePosts() {
  return useSyncExternalStore(subscribe, snapshot.posts, snapshot.posts);
}

export function useExperiences() {
  return useSyncExternalStore(subscribe, snapshot.experiences, snapshot.experiences);
}

export function useSkillGroups() {
  return useSyncExternalStore(subscribe, snapshot.skills, snapshot.skills);
}

export function useProfile() {
  return useSyncExternalStore(subscribe, snapshot.profile, snapshot.profile);
}

export function relatedPosts(posts, post, count = 2) {
  return posts
    .filter((entry) => entry.slug !== post.slug)
    .sort((a, b) => {
      const score = (item) =>
        (item.category === post.category ? 2 : 0) +
        item.tags.filter((tag) => post.tags.includes(tag)).length;
      return score(b) - score(a);
    })
    .slice(0, count);
}

export function adjacentPosts(posts, post) {
  const index = posts.findIndex((entry) => entry.slug === post.slug);
  return {
    previous: posts[index + 1] ?? null,
    next: posts[index - 1] ?? null,
  };
}
