import { describe, it, expect } from 'vitest';
import { extractCodes, mergeEntries, getQueue } from '../src/logic.js';

describe('extractCodes', ()=>{
  it('extracts single code', ()=>{
    const s = 'Use CODE-12345 now';
    expect(extractCodes(s,'[A-Z0-9\-]{5,30}')).toEqual(['CODE-12345']);
  });
  it('dedupes duplicates', ()=>{
    const s = 'A A A CODE1 CODE1 CODE1';
    expect(extractCodes(s,'CODE1|CODE1')).toEqual(['CODE1']);
  });
  it('throws on invalid regex', ()=>{
    expect(()=> extractCodes('x','[')).toThrow();
  });
});

describe('mergeEntries', ()=>{
  it('merges new entries and preserves existing fields', ()=>{
    const ex = [{code:'A', note:'old', seen:'2025-01-01'}];
    const inc = [{code:'A', note:'new'}];
    const out = mergeEntries(ex,inc);
    expect(out.length).toBe(1);
    expect(out[0].note).toBe('new');
    expect(out[0].seen).toBe('2025-01-01');
  });
  it('adds new code', ()=>{
    const ex = []; const inc = [{code:'B', note:'n'}];
    const out = mergeEntries(ex,inc);
    expect(out.find(x=>x.code==='B')).toBeTruthy();
  });
});

describe('getQueue', ()=>{
  it('filters queued non-used', ()=>{
    const arr = [{code:'A', queued:true, status:'unknown'},{code:'B', queued:true, status:'used'}];
    const q = getQueue(arr);
    expect(q.map(x=>x.code)).toEqual(['A']);
  });
});
