<script lang="ts">
	const currentYear = new Date().getFullYear();
</script>

<footer class="footer">
	<div class="footer-container">
		<div class="footer-section">
			<h3 class="footer-title">Global Sovereign Network</h3>
			<p class="footer-text">
				Building fault-tolerant, offline-first infrastructure for struggling communities worldwide.
			</p>
			<p class="footer-covenant">
				<em>"We raise a tower of stored light. When the world goes dark, our archive glows."</em>
			</p>
		</div>

		<div class="footer-section">
			<h4 class="footer-heading">Quick Links</h4>
			<ul class="footer-links">
				<li><a href="/">Dashboard</a></li>
				<li><a href="/sectors">Sectors</a></li>
				<li><a href="/countries">Countries</a></li>
				<li><a href="/projects">Projects</a></li>
				<li><a href="/codex">Codex</a></li>
			</ul>
		</div>

		<div class="footer-section">
			<h4 class="footer-heading">Sectors</h4>
			<ul class="footer-links">
				<li><a href="/sectors/agriculture">Agriculture</a></li>
				<li><a href="/sectors/minerals">Minerals</a></li>
				<li><a href="/sectors/energy">Energy</a></li>
				<li><a href="/sectors/technology">Technology</a></li>
				<li><a href="/sectors/health">Health</a></li>
				<li><a href="/sectors/education">Education</a></li>
			</ul>
		</div>

		<div class="footer-section">
			<h4 class="footer-heading">Resources</h4>
			<ul class="footer-links">
				<li><a href="/docs">Documentation</a></li>
				<li><a href="/api">API</a></li>
				<li><a href="/status">System Status</a></li>
				<li><a href="https://github.com/Vundla/Global-Signal_-Charter" target="_blank" rel="noopener">
					GitHub
				</a></li>
			</ul>
		</div>
	</div>

	<div class="footer-bottom">
		<p class="footer-copyright">
			© {currentYear} Global Sovereign Covenant. Built with Elixir/OTP & SvelteKit.
		</p>
		<p class="footer-philosophy">
			<strong>Philosophy:</strong> "Crash It If You Can" - Built on Erlang/BEAM principles
		</p>
	</div>
</footer>

<style>
	.footer {
		background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
		color: #e2e8f0;
		margin-top: 4rem;
		padding: 3rem 0 1rem;
	}

	.footer-container {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
		gap: 2rem;
		max-width: 1400px;
		margin: 0 auto;
		padding: 0 2rem;
	}

	.footer-section {
		display: flex;
		flex-direction: column;
		gap: 1rem;
	}

	.footer-title {
		margin: 0;
		font-size: 1.5rem;
		color: #60a5fa;
		font-weight: 700;
	}

	.footer-text {
		margin: 0;
		font-size: 0.875rem;
		line-height: 1.6;
		color: #cbd5e1;
	}

	.footer-covenant {
		margin: 0.5rem 0 0 0;
		font-size: 0.875rem;
		font-style: italic;
		color: #94a3b8;
		border-left: 3px solid #3b82f6;
		padding-left: 1rem;
	}

	.footer-heading {
		margin: 0;
		font-size: 1rem;
		font-weight: 600;
		color: #f1f5f9;
		text-transform: uppercase;
		letter-spacing: 0.05em;
	}

	.footer-links {
		list-style: none;
		padding: 0;
		margin: 0;
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	.footer-links a {
		color: #cbd5e1;
		text-decoration: none;
		font-size: 0.875rem;
		transition: color 0.2s;
	}

	.footer-links a:hover {
		color: #60a5fa;
	}

	.footer-bottom {
		max-width: 1400px;
		margin: 0 auto;
		padding: 2rem 2rem 1rem;
		border-top: 1px solid #334155;
		margin-top: 2rem;
		text-align: center;
	}

	.footer-copyright,
	.footer-philosophy {
		margin: 0.5rem 0;
		font-size: 0.875rem;
		color: #94a3b8;
	}

	.footer-philosophy {
		color: #64748b;
	}

	@media (max-width: 768px) {
		.footer-container {
			grid-template-columns: 1fr;
		}
	}
</style>
