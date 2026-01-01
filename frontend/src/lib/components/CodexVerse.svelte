<script lang="ts">
	import { codexVerses, type CodexVerse } from '$lib/codex';

	export let verse: CodexVerse | undefined = undefined;
	export let display: 'full' | 'quote' = 'quote';
	export let theme: 'light' | 'dark' = 'dark';

	// If no verse provided, pick a random one
	if (!verse) {
		verse = codexVerses[Math.floor(Math.random() * codexVerses.length)];
	}
</script>

<div class="codex-verse {theme}">
	<div class="verse-header">
		<span class="phase-badge">{verse?.phase}</span>
		<span class="sector-badge">{verse?.sector}</span>
	</div>

	{#if display === 'full' && verse}
		<div class="verse-text full">
			{#each verse.verse.split('\n') as line}
				<p>{line}</p>
			{/each}
		</div>
	{:else if verse}
		<div class="verse-text quote">
			<p>"{verse.shortQuote}"</p>
		</div>
	{/if}

	<div class="verse-footer">
		<span class="closing">Resilience becomes law, unity becomes inheritance</span>
	</div>
</div>

<style>
	.codex-verse {
		border-left: 4px solid var(--border-color);
		padding: 1.5rem;
		margin: 1rem 0;
		border-radius: 0.5rem;
		font-family: 'Georgia', serif;
		line-height: 1.8;
	}

	.codex-verse.light {
		background: #f9f7f4;
		--border-color: #d4a574;
	}

	.codex-verse.dark {
		background: #1a1a1a;
		--border-color: #b8860b;
		color: #e0e0e0;
	}

	.verse-header {
		display: flex;
		gap: 0.75rem;
		margin-bottom: 1rem;
		font-size: 0.85rem;
	}

	.phase-badge,
	.sector-badge {
		padding: 0.25rem 0.75rem;
		border-radius: 1rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.05em;
	}

	.light .phase-badge {
		background: #d4a574;
		color: #2c2c2c;
	}

	.dark .phase-badge {
		background: #b8860b;
		color: #1a1a1a;
	}

	.light .sector-badge {
		background: #e8d7c3;
		color: #2c2c2c;
	}

	.dark .sector-badge {
		background: #8b7355;
		color: #f5f5f5;
	}

	.verse-text {
		margin: 1rem 0;
	}

	.verse-text p {
		margin: 0.5rem 0;
		font-style: italic;
	}

	.verse-text.full p {
		text-align: center;
	}

	.verse-text.quote p {
		text-align: center;
		font-size: 1.1rem;
		font-weight: 500;
	}

	.verse-footer {
		margin-top: 1rem;
		text-align: right;
		font-size: 0.9rem;
		opacity: 0.8;
	}

	.closing {
		font-style: italic;
		font-weight: 500;
	}
</style>
