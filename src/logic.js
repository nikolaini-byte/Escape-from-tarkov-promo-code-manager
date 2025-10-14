/**
 * Core logic extracted for unit testing.
 * Exports: extractCodes(text, regexStr), mergeEntries(existing, incoming), getQueue(entries)
 */

/**
 * Extract unique codes from text using a regex string.
 * @param {string} text
 * @param {string} regexStr
 * @returns {string[]}
 */
export function extractCodes(text, regexStr='[A-Z0-9\\-]{5,30}'){
  if(typeof text !== 'string') throw new TypeError('text must be a string');
  if(typeof regexStr !== 'string') throw new TypeError('regexStr must be a string');
  let re;
  try{ re = new RegExp(regexStr,'g'); }catch(e){ throw new Error('Invalid regex: '+e.message); }
  const matches = text.match(re) || [];
  const seen = new Set();
  const out = [];
  for(const m of matches){ if(!seen.has(m)){ seen.add(m); out.push(m); } }
  return out;
}

/**
 * Merge two arrays of entries deduping by `code`.
 * Incoming entries override existing fields when provided (not undefined).
 * @param {Array<Object>} existing
 * @param {Array<Object>} incoming
 * @returns {Array<Object>} merged array
 */
export function mergeEntries(existing, incoming){
  if(!Array.isArray(existing) || !Array.isArray(incoming)) throw new TypeError('existing and incoming must be arrays');
  const map = new Map();
  for(const e of existing){ if(!e || !e.code) continue; map.set(e.code, Object.assign({}, e)); }
  for(const inc of incoming){ if(!inc || !inc.code) continue; const cur = map.get(inc.code) || {};
    // merge: fields from inc if not undefined, otherwise keep cur
    const merged = Object.assign({}, cur);
    for(const k of Object.keys(inc)){
      if(inc[k] !== undefined) merged[k] = inc[k];
    }
    map.set(inc.code, merged);
  }
  // return array sorted by seen desc if present, else insertion
  const arr = Array.from(map.values());
  arr.sort((a,b)=>{ const sa = a.seen||''; const sb = b.seen||''; if(sa===sb) return 0; return sa > sb ? -1 : 1; });
  return arr;
}

/**
 * Return queued entries that are not used.
 * @param {Array<Object>} entries
 * @returns {Array<Object>}
 */
export function getQueue(entries){
  if(!Array.isArray(entries)) throw new TypeError('entries must be an array');
  return entries.filter(e=> e && e.queued && e.status !== 'used');
}
