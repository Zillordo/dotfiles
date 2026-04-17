#!/usr/bin/env node

import { execFileSync } from 'node:child_process';
import { copyFile, mkdir, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, extname, join, relative, resolve } from 'node:path';

const SUPPORTED_EXTENSIONS = new Set(['.js', '.jsx', '.ts', '.tsx', '.mjs', '.cjs', '.mts', '.cts']);
const ALWAYS_IGNORED_SEGMENTS = new Set([
  '.git',
  'node_modules',
  'dist',
  'build',
  'coverage',
  '.next',
  '.nx',
  'storybook-static',
  '__snapshots__',
  '__mocks__',
]);
const GENERATED_SEGMENTS = new Set(['generated', '__generated__']);
const DEFAULTS = {
  minLines: 8,
  minTokens: 80,
  fallowMode: 'semantic',
  ignoreImports: true,
  includeTests: false,
  includeGenerated: false,
};

function parseArgs(argv) {
  const passthroughIndex = argv.indexOf('--');
  const ownArgs = passthroughIndex === -1 ? argv : argv.slice(0, passthroughIndex);
  const passthrough = passthroughIndex === -1 ? [] : argv.slice(passthroughIndex + 1);

  const args = {
    scope: null,
    outDir: 'docs/analysis',
    includeTests: false,
    includeGenerated: false,
    minLines: DEFAULTS.minLines,
    minTokens: DEFAULTS.minTokens,
    fallowMode: DEFAULTS.fallowMode,
    keepTemp: false,
    quiet: false,
    jscpdArgs: [],
    fallowArgs: [],
    passthrough,
  };

  for (let i = 0; i < ownArgs.length; i += 1) {
    const arg = ownArgs[i];
    const next = ownArgs[i + 1];

    switch (arg) {
      case '--scope':
        args.scope = next;
        i += 1;
        break;
      case '--out-dir':
        args.outDir = next;
        i += 1;
        break;
      case '--include-tests':
        args.includeTests = true;
        break;
      case '--include-generated':
        args.includeGenerated = true;
        break;
      case '--min-lines':
        args.minLines = Number(next);
        i += 1;
        break;
      case '--min-tokens':
        args.minTokens = Number(next);
        i += 1;
        break;
      case '--fallow-mode':
        args.fallowMode = next;
        i += 1;
        break;
      case '--keep-temp':
        args.keepTemp = true;
        break;
      case '--quiet':
        args.quiet = true;
        break;
      case '--jscpd-args':
        args.jscpdArgs = next ? next.split(' ').filter(Boolean) : [];
        i += 1;
        break;
      case '--fallow-args':
        args.fallowArgs = next ? next.split(' ').filter(Boolean) : [];
        i += 1;
        break;
      case '-h':
      case '--help':
        printHelp();
        process.exit(0);
      default:
        if (!args.scope) {
          args.scope = arg;
        } else {
          throw new Error(`Unknown argument: ${arg}`);
        }
    }
  }

  if (!Number.isFinite(args.minLines) || args.minLines <= 0) {
    throw new Error('--min-lines must be a positive number');
  }
  if (!Number.isFinite(args.minTokens) || args.minTokens <= 0) {
    throw new Error('--min-tokens must be a positive number');
  }

  return args;
}

function printHelp() {
  console.log(`Run a combined jscpd + fallow duplicate audit on bw-react code.

Usage:
  node /home/allank/.pi/agent/skills/duplication-auditor/scripts/run-duplication-auditor.mjs [scope] [options] [-- <extra jscpd args>]

Examples:
  node /home/allank/.pi/agent/skills/duplication-auditor/scripts/run-duplication-auditor.mjs
  node /home/allank/.pi/agent/skills/duplication-auditor/scripts/run-duplication-auditor.mjs provider-bw/libs/bw-react-cockpit/
  node /home/allank/.pi/agent/skills/duplication-auditor/scripts/run-duplication-auditor.mjs provider-bw/libs/bw-react-marketplace/ --min-lines 10

Options:
  --scope <path>            Narrow scan to a bw-react subtree
  --out-dir <path>          Output directory (default: docs/analysis)
  --include-tests           Include test/spec files
  --include-generated       Include generated files
  --min-lines <n>           Minimum duplicated lines for both tools (default: 8)
  --min-tokens <n>          jscpd minimum token threshold (default: 80)
  --fallow-mode <mode>      fallow mode: strict|mild|weak|semantic (default: semantic)
  --jscpd-args "..."        Extra args appended to jscpd
  --fallow-args "..."       Extra args appended to fallow
  --keep-temp               Keep filtered temp workspace
  --quiet                   Reduce logging
  -h, --help                Show help
`);
}

function run(cmd, args, opts = {}) {
  return execFileSync(cmd, args, {
    encoding: 'utf8',
    stdio: ['ignore', 'pipe', 'pipe'],
    maxBuffer: 128 * 1024 * 1024,
    ...opts,
  });
}

function normalizePath(value) {
  return value.replace(/\\/g, '/').replace(/\/+$|^\.\//g, '');
}

function assertBwReactScope(scope) {
  if (scope && !scope.includes('bw-react')) {
    throw new Error(`Scope must contain "bw-react". Got: ${scope}`);
  }
}

function isInsideBwReactFolder(relativePath) {
  const parts = normalizePath(relativePath).split('/');
  return parts.slice(0, -1).some((part) => part.includes('bw-react'));
}

function pathContainsSrc(relativePath) {
  return normalizePath(relativePath).split('/').includes('src');
}

function shouldIncludeFile(relativePath, { includeTests, includeGenerated, scopePath }) {
  const normalized = normalizePath(relativePath);
  const parts = normalized.split('/');
  const fileName = parts.at(-1) ?? '';
  const extension = extname(fileName).toLowerCase();

  if (scopePath) {
    const s = normalizePath(scopePath);
    if (!(normalized === s || normalized.startsWith(`${s}/`))) {
      return false;
    }
  }

  if (!SUPPORTED_EXTENSIONS.has(extension)) {
    return false;
  }
  if (!isInsideBwReactFolder(normalized)) {
    return false;
  }
  if (!pathContainsSrc(normalized)) {
    return false;
  }
  if (parts.some((part) => ALWAYS_IGNORED_SEGMENTS.has(part))) {
    return false;
  }
  if (!includeGenerated && parts.some((part) => GENERATED_SEGMENTS.has(part))) {
    return false;
  }
  if (/\.(stories|story)\.[^.]+$/i.test(fileName)) {
    return false;
  }
  if (!includeTests) {
    if (parts.includes('__tests__')) {
      return false;
    }
    if (/\.(test|spec)\.[^.]+$/i.test(fileName)) {
      return false;
    }
  }
  return true;
}

async function copySelectedFiles(repoRoot, files, tempRoot) {
  for (const relativePath of files) {
    const sourcePath = resolve(repoRoot, relativePath);
    const destinationPath = join(tempRoot, relativePath);
    await mkdir(dirname(destinationPath), { recursive: true });
    await copyFile(sourcePath, destinationPath);
  }
}

function getRepoRoot() {
  return run('git', ['rev-parse', '--show-toplevel']).trim();
}

function getSelectedFiles(repoRoot, args) {
  const gitOutput = run('git', ['-C', repoRoot, 'ls-files', '-co', '--exclude-standard']);
  return gitOutput
    .split('\n')
    .map((line) => normalizePath(line.trim()))
    .filter(Boolean)
    .filter((file) => shouldIncludeFile(file, { ...args, scopePath: args.scope ? normalizePath(args.scope) : null }));
}

function basenameLabel(scope) {
  return (scope || 'bw-react').replace(/[^a-zA-Z0-9._-]+/g, '_');
}

function parseJsonSafe(text, label) {
  try {
    return JSON.parse(text);
  } catch (error) {
    throw new Error(`Failed to parse ${label} JSON: ${error instanceof Error ? error.message : String(error)}`);
  }
}

function extractFallowGroups(report) {
  const groups = Array.isArray(report.clone_groups) ? report.clone_groups : [];
  return groups.map((group, index) => {
    const files = [...new Set((group.instances ?? []).map((instance) => normalizePath(instance.file)))].sort();
    return {
      id: `fallow-${index + 1}`,
      files,
      lineCount: group.line_count ?? 0,
      instanceCount: (group.instances ?? []).length,
      kind: 'fallow',
    };
  });
}

function extractJscpdGroups(report) {
  const groups = Array.isArray(report.duplicates) ? report.duplicates : [];
  return groups.map((group, index) => {
    const files = [group.firstFile?.name, group.secondFile?.name].filter(Boolean).map(normalizePath);
    return {
      id: `jscpd-${index + 1}`,
      files: [...new Set(files)].sort(),
      lineCount: group.lines ?? 0,
      instanceCount: files.length,
      kind: 'jscpd',
    };
  });
}

function filePairKey(files) {
  return [...new Set(files)].sort().join(' :: ');
}

function isMeaningfulGroup(group) {
  if (group.files.length < 2) {
    return false;
  }
  const joined = group.files.join(' ');
  if (/__tests__|\.test\.|\.spec\.|\.stories\.|\.story\.|__generated__|\/generated\//i.test(joined)) {
    return false;
  }
  if (group.lineCount < 8) {
    return false;
  }
  return true;
}

function classifyRefactorValue(group, overlap) {
  if (group.lineCount >= 40 || overlap) return 'high';
  if (group.lineCount >= 20) return 'medium';
  return 'low';
}

function summarizeTopFiles(groups) {
  const counts = new Map();
  for (const group of groups) {
    for (const file of group.files) {
      const entry = counts.get(file) ?? { groups: 0, lines: 0 };
      entry.groups += 1;
      entry.lines += group.lineCount;
      counts.set(file, entry);
    }
  }
  return [...counts.entries()]
    .map(([file, data]) => ({ file, ...data }))
    .sort((a, b) => b.lines - a.lines || b.groups - a.groups || a.file.localeCompare(b.file))
    .slice(0, 12);
}

function buildCombinedSummary({ scope, selectedFiles, manifest, jscpdReport, fallowReport }) {
  const jscpdGroups = extractJscpdGroups(jscpdReport).filter(isMeaningfulGroup);
  const fallowGroups = extractFallowGroups(fallowReport).filter(isMeaningfulGroup);

  const jscpdMap = new Map(jscpdGroups.map((group) => [filePairKey(group.files), group]));
  const fallowMap = new Map(fallowGroups.map((group) => [filePairKey(group.files), group]));

  const both = [];
  const jscpdOnly = [];
  const fallowOnly = [];

  for (const [key, group] of jscpdMap) {
    if (fallowMap.has(key)) {
      both.push({ jscpd: group, fallow: fallowMap.get(key) });
    } else {
      jscpdOnly.push(group);
    }
  }
  for (const [key, group] of fallowMap) {
    if (!jscpdMap.has(key)) {
      fallowOnly.push(group);
    }
  }

  const curated = [
    ...both.map((pair) => ({
      files: pair.jscpd.files,
      lineCount: Math.max(pair.jscpd.lineCount, pair.fallow.lineCount),
      toolSupport: 'both',
      refactorValue: classifyRefactorValue(pair.fallow, true),
    })),
    ...jscpdOnly.map((group) => ({
      files: group.files,
      lineCount: group.lineCount,
      toolSupport: 'jscpd-only',
      refactorValue: classifyRefactorValue(group, false),
    })),
    ...fallowOnly.map((group) => ({
      files: group.files,
      lineCount: group.lineCount,
      toolSupport: 'fallow-only',
      refactorValue: classifyRefactorValue(group, false),
    })),
  ].sort((a, b) => {
    const rank = { high: 3, medium: 2, low: 1 };
    return rank[b.refactorValue] - rank[a.refactorValue] || b.lineCount - a.lineCount;
  });

  const topFiles = summarizeTopFiles(curated);
  const topFamilies = curated.slice(0, 15);

  return `# Combined duplication audit summary for \`${scope || 'bw-react'}\`

## Scan surface
- Requested scope: \`${scope || 'repo-wide bw-react'}\`
- Effective file set: **${selectedFiles.length}** production-leaning source files under bw-react src trees
- Tests included: ${manifest.includeTests ? 'yes' : 'no'}
- Generated files included: ${manifest.includeGenerated ? 'yes' : 'no'}
- Shared filtered workspace used for both tools: yes

## Tool configuration
### jscpd
- min-lines: \`${manifest.minLines}\`
- min-tokens: \`${manifest.minTokens}\`
- mode: default jscpd matching
- runner: \`npx -y jscpd\`

### fallow
- mode: \`${manifest.fallowMode}\`
- min-lines: \`${manifest.minLines}\`
- ignore-imports: yes
- runner: \`npx -y fallow dupes\`

## High-level results
- Meaningful jscpd groups after filtering: **${jscpdGroups.length}**
- Meaningful fallow groups after filtering: **${fallowGroups.length}**
- Reported by both tools: **${both.length}**
- Only in jscpd: **${jscpdOnly.length}**
- Only in fallow: **${fallowOnly.length}**

## Where duplication is concentrated
${topFiles.length === 0 ? '- No meaningful duplicate hotspots survived filtering.' : topFiles.map((item) => `- \`${item.file}\` — ${item.groups} groups / ${item.lines} duplicated lines`).join('\n')}

## Highest-value duplicate families
${topFamilies.length === 0 ? '- No meaningful families survived filtering.' : topFamilies.map((item, index) => `### ${index + 1}) ${item.refactorValue.toUpperCase()} · ${item.toolSupport} · ${item.lineCount} lines\n${item.files.map((file) => `- \`${file}\``).join('\n')}`).join('\n\n')}

## Interpretation guidance
- **both**: strongest candidates; exact and semantic duplication agree
- **jscpd-only**: usually exact copy/paste or very close variants
- **fallow-only**: often structurally similar flows worth reviewing for shared abstractions

## Conclusion
This summary is already curated toward duplicates that are more likely to reduce code complexity if refactored. Prioritize both-tool matches first, then review larger fallow-only families for shared workflow abstractions.
`;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  assertBwReactScope(args.scope || 'bw-react');

  const repoRoot = getRepoRoot();
  const outDir = resolve(repoRoot, args.outDir);
  const selectedFiles = getSelectedFiles(repoRoot, args);

  if (selectedFiles.length === 0) {
    throw new Error('No matching bw-react src source files found after filtering.');
  }

  await mkdir(outDir, { recursive: true });
  const tempRoot = await mkdtemp(join(tmpdir(), 'duplication-auditor-'));
  const label = basenameLabel(args.scope);
  const jscpdOut = join(outDir, `jscpd-${label}.json`);
  const fallowOut = join(outDir, `fallow-${label}.json`);
  const manifestOut = join(outDir, `duplication-manifest-${label}.json`);
  const summaryOut = join(outDir, `duplication-summary-${label}.md`);

  try {
    await copySelectedFiles(repoRoot, selectedFiles, tempRoot);

    const manifest = {
      repoRoot,
      requestedScope: args.scope || 'bw-react',
      selectedFiles: selectedFiles.length,
      minLines: args.minLines,
      minTokens: args.minTokens,
      fallowMode: args.fallowMode,
      includeTests: args.includeTests,
      includeGenerated: args.includeGenerated,
      tempRoot,
    };
    await writeFile(manifestOut, `${JSON.stringify(manifest, null, 2)}\n`);

    if (!args.quiet) {
      console.log(`Filtered workspace: ${tempRoot}`);
      console.log(`Selected files: ${selectedFiles.length}`);
      console.log('Running jscpd...');
    }

    const jscpdWorkDir = join(tempRoot, '.jscpd-report');
    await mkdir(jscpdWorkDir, { recursive: true });
    run('npx', [
      '-y',
      'jscpd',
      '--reporters',
      'json',
      '--output',
      jscpdWorkDir,
      '--min-lines',
      String(args.minLines),
      '--min-tokens',
      String(args.minTokens),
      '.',
      ...args.jscpdArgs,
      ...args.passthrough,
    ], { cwd: tempRoot });

    const jscpdReportPath = join(jscpdWorkDir, 'jscpd-report.json');
    if (!existsSync(jscpdReportPath)) {
      throw new Error('jscpd report was not generated.');
    }
    const jscpdText = await readFile(jscpdReportPath, 'utf8');
    await writeFile(jscpdOut, jscpdText);

    if (!args.quiet) {
      console.log('Running fallow...');
    }

    const fallowText = run('npx', [
      '-y',
      'fallow',
      'dupes',
      '--root',
      tempRoot,
      '--format',
      'json',
      '--mode',
      args.fallowMode,
      '--min-lines',
      String(args.minLines),
      '--ignore-imports',
      ...args.fallowArgs,
    ], { cwd: repoRoot });
    await writeFile(fallowOut, fallowText);

    const jscpdReport = parseJsonSafe(jscpdText, 'jscpd');
    const fallowReport = parseJsonSafe(fallowText, 'fallow');
    const summary = buildCombinedSummary({
      scope: args.scope,
      selectedFiles,
      manifest,
      jscpdReport,
      fallowReport,
    });
    await writeFile(summaryOut, summary);

    if (!args.quiet) {
      console.log(`Wrote summary: ${relative(repoRoot, summaryOut)}`);
      console.log(`Wrote jscpd report: ${relative(repoRoot, jscpdOut)}`);
      console.log(`Wrote fallow report: ${relative(repoRoot, fallowOut)}`);
      console.log(`Wrote manifest: ${relative(repoRoot, manifestOut)}`);
    }
  } finally {
    if (!args.keepTemp) {
      await rm(tempRoot, { recursive: true, force: true });
    }
  }
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
});
