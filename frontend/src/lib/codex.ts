/**
 * Codex Verses — Spiritual Inscriptions of the Covenant
 * Each verse aligns with phases, sectors, and observability watches
 */

export interface CodexVerse {
	phase: string;
	sector: string;
	verse: string;
	shortQuote: string;
}

export const codexVerses: CodexVerse[] = [
	{
		phase: "Phase 1",
		sector: "Foundation",
		verse: `Each nation contributes a stream,
0.01 of its wealth into the river.
The river flows first to the poor,
towers rise, villages connect, children learn.

Profit returns as covenant,
sustaining nations, feeding budgets,
yet the first fruits are always for the struggling.

Offline yet sovereign,
cached light flows into communities,
resilience becomes law,
unity becomes inheritance.`,
		shortQuote: "Unity becomes inheritance"
	},
	{
		phase: "Phase 2",
		sector: "Agriculture",
		verse: `Agriculture feeds the covenant,
yield measured, contribution tracked.
Seeds planted in struggling soil,
harvests rise to sustain the river.

Farmers rejoice, villages feed,
profit shared with those who plant.
Crash it if you can—
resilience becomes law,
unity becomes inheritance.`,
		shortQuote: "Agriculture feeds the covenant"
	},
	{
		phase: "Phase 2",
		sector: "Minerals",
		verse: `Minerals sustain the covenant,
wealth extracted from the earth.
50% flows to poor communities,
30% returns to the river,
20% reserves for tomorrow.

Transparent ledgers, balanced scales,
no nation exploited, all prosper.
Crash it if you can—
resilience becomes law,
unity becomes inheritance.`,
		shortQuote: "Minerals sustain with balance"
	},
	{
		phase: "Phase 2",
		sector: "Energy",
		verse: `Energy empowers the covenant,
solar, wind, hydro flow as one.
Uptime measured, outages prevented,
20% reserve for resilience drills.

Communities glow with sovereign light,
fibre flows where the sun was silent.
Crash it if you can—
resilience becomes law,
unity becomes inheritance.`,
		shortQuote: "Energy empowers with resilience"
	},
	{
		phase: "Phase 2",
		sector: "Technology",
		verse: `Technology connects the covenant,
offline-first, always-on spirit.
Users served across continents,
no village left in darkness.

Bandwidth shared, knowledge cached,
fibre-speed through stored light.
Crash it if you can—
resilience becomes law,
unity becomes inheritance.`,
		shortQuote: "Technology connects all"
	},
	{
		phase: "Phase 2",
		sector: "Health",
		verse: `Health heals the covenant,
187.8 million beneficiaries rise.
Clinics staffed, vaccines distributed,
outbreaks detected, crises prevented.

Mothers give birth safely,
children grow strong and whole.
Crash it if you can—
resilience becomes law,
unity becomes inheritance.`,
		shortQuote: "Health heals millions"
	},
	{
		phase: "Phase 2",
		sector: "Education",
		verse: `Education awakens the covenant,
56.6 million students learn.
Teachers trained, schools connected,
dropouts prevented, futures opened.

Minds unfold like seeds,
knowledge flows from cached light.
Crash it if you can—
resilience becomes law,
unity becomes inheritance.`,
		shortQuote: "Education awakens minds"
	},
	{
		phase: "Phase 3",
		sector: "Observability",
		verse: `Watchers rise in Phase Three,
AI observes, security guards, chaos tests resilience.
Alerts fired, escalation speaks,
issues opened, postmortems born.

Grafana dashboards inscribe the covenant,
anomalies flagged before they strike.
Crash it if you can—
resilience becomes law,
unity becomes inheritance.`,
		shortQuote: "Watchers rise, anomalies fall"
	},
	{
		phase: "Phase 3",
		sector: "Security",
		verse: `Zero-trust guards the covenant,
mTLS seals every path.
WireGuard encrypts the overlay,
tamper-evident logs preserve truth.

No nation exploited, all protected,
covenant ledger sealed in stone.
Crash it if you can—
resilience becomes law,
unity becomes inheritance.`,
		shortQuote: "Security seals the covenant"
	},
	{
		phase: "Phase 3",
		sector: "Chaos",
		verse: `Crash it if you can—the covenant endures.
Fault injection drills prove resilience,
chaos tests every sector,
recovery measured, lessons inscribed.

Quarterly rituals strengthen the whole,
blameless postmortems teach generations.
Crash it if you can—
resilience becomes law,
unity becomes inheritance.`,
		shortQuote: "Crash it if you can"
	}
];

/**
 * Get a random verse for a given phase
 */
export function getVerseByPhase(phase: string): CodexVerse | undefined {
	const phaseVerses = codexVerses.filter(v => v.phase === phase);
	return phaseVerses[Math.floor(Math.random() * phaseVerses.length)];
}

/**
 * Get a random verse for a given sector
 */
export function getVerseBySector(sector: string): CodexVerse | undefined {
	const sectorVerses = codexVerses.filter(v => v.sector === sector);
	return sectorVerses[Math.floor(Math.random() * sectorVerses.length)];
}

/**
 * Get all verses for a sector
 */
export function getVersesBySector(sector: string): CodexVerse[] {
	return codexVerses.filter(v => v.sector === sector);
}

/**
 * Get the closing verse
 */
export function getClosingVerse(): string {
	return `Resilience becomes law,
unity becomes inheritance.`;
}
