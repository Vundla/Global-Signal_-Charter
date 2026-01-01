#!/usr/bin/env elixir

# UbuntuNet Global - Development Scoring Tracker
# Tracks progress across 5 phases with 90% review gates
# Database: global_DB, Schema: public, Owner: global-signal_-charter

Mix.install([
  {:postgrex, "~> 0.17"},
  {:jason, "~> 1.4"}
])

defmodule ScoringTracker do
  @moduledoc """
  Automated scoring system for UbuntuNet Global implementation phases.
  Queries the dev_checklist table and calculates aggregate scores.
  """

  @db_config [
    hostname: "localhost",
    username: "global-signal_-charter",
    password: "Mv@10111",
    database: "global_DB"
  ]

  @phases [
    "foundation",
    "data_caching",
    "ai_security",
    "chaos",
    "community"
  ]

  def start do
    IO.puts("\n🐆🦁🐇 UbuntuNet Global - Scoring Tracker")
    IO.puts("=" <> String.duplicate("=", 60))

    case Postgrex.start_link(@db_config) do
      {:ok, conn} ->
        display_scorecard(conn)
        check_review_gates(conn)
        Postgrex.close(conn)

      {:error, error} ->
        IO.puts("❌ Database connection failed: #{inspect(error)}")
        IO.puts("\n💡 Initialize database first:")
        IO.puts("   sudo -u postgres psql -f backend/priv/repo/init.sql")
    end
  end

  defp display_scorecard(conn) do
    IO.puts("\n📊 MASTER SCORECARD\n")

    total_score = 0

    Enum.each(@phases, fn phase ->
      score = calculate_phase_score(conn, phase)
      status = phase_status(score)
      gate_passed = if score >= 90, do: "✅", else: "❌"

      phase_name = format_phase_name(phase)
      IO.puts("#{status} #{phase_name}: #{score}/100 #{gate_passed}")

      total_score = total_score + score
    end)

    total_score = calculate_total_score(conn)
    production_ready = if total_score >= 450, do: "✅", else: "❌"

    IO.puts("\n" <> String.duplicate("-", 60))
    IO.puts("TOTAL: #{total_score}/500 #{production_ready}")

    if total_score >= 450 do
      IO.puts("\n🎉 Production Ready! Deploy to Fly.io")
    else
      remaining = 450 - total_score
      IO.puts("\n⚠️  Need #{remaining} more points for production (450 minimum)")
    end
  end

  defp calculate_phase_score(conn, phase) do
    query = """
    SELECT COALESCE(AVG(score), 0) as avg_score
    FROM dev_checklist
    WHERE phase = $1
    """

    case Postgrex.query(conn, query, [phase]) do
      {:ok, %{rows: [[score]]}} -> round(score)
      _ -> 0
    end
  end

  defp calculate_total_score(conn) do
    query = """
    SELECT COALESCE(SUM(score), 0) as total
    FROM (
      SELECT phase, AVG(score) as score
      FROM dev_checklist
      GROUP BY phase
    ) phase_scores
    """

    case Postgrex.query(conn, query, []) do
      {:ok, %{rows: [[total]]}} -> round(total)
      _ -> 0
    end
  end

  defp check_review_gates(conn) do
    IO.puts("\n🚦 REVIEW GATE STATUS\n")

    Enum.each(@phases, fn phase ->
      score = calculate_phase_score(conn, phase)
      passed = score >= 90
      gate_status = if passed, do: "✅ PASSED", else: "❌ BLOCKED"

      phase_name = format_phase_name(phase)
      IO.puts("#{phase_name}: #{gate_status} (#{score}/100)")

      unless passed do
        missing_tasks = get_incomplete_tasks(conn, phase)
        if length(missing_tasks) > 0 do
          IO.puts("  Incomplete tasks:")
          Enum.each(missing_tasks, fn task ->
            IO.puts("    - #{task}")
          end)
        end
      end
    end)
  end

  defp get_incomplete_tasks(conn, phase) do
    query = """
    SELECT task
    FROM dev_checklist
    WHERE phase = $1 AND status != 'completed'
    ORDER BY id
    LIMIT 5
    """

    case Postgrex.query(conn, query, [phase]) do
      {:ok, %{rows: rows}} -> Enum.map(rows, fn [task] -> task end)
      _ -> []
    end
  end

  defp phase_status(score) when score >= 90, do: "🟢"
  defp phase_status(score) when score >= 70, do: "🟡"
  defp phase_status(_), do: "🔴"

  defp format_phase_name(phase) do
    phase
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
    |> String.pad_trailing(20)
  end

  def update_task(conn, phase, task_name, score, status) do
    query = """
    INSERT INTO dev_checklist (phase, task, score, status, updated_at)
    VALUES ($1, $2, $3, $4, NOW())
    ON CONFLICT (phase, task)
    DO UPDATE SET
      score = EXCLUDED.score,
      status = EXCLUDED.status,
      updated_at = NOW()
    """

    case Postgrex.query(conn, query, [phase, task_name, score, status]) do
      {:ok, _} -> IO.puts("✅ Updated: #{task_name} → #{score}/100 (#{status})")
      {:error, error} -> IO.puts("❌ Error: #{inspect(error)}")
    end
  end

  def run_automated_checks do
    IO.puts("\n🤖 Running Automated Checks...\n")

    checks = [
      {"Backend Tests", "cd backend && mix test", 25},
      {"Frontend Tests", "cd frontend && npm test", 25},
      {"Security Scan", "cd backend && mix sobelow --config", 25},
      {"Code Coverage", "cd backend && mix coveralls", 25}
    ]

    Enum.each(checks, fn {name, command, points} ->
      IO.puts("Running: #{name}")

      case System.cmd("sh", ["-c", command], stderr_to_stdout: true) do
        {_output, 0} ->
          IO.puts("  ✅ PASS (+#{points} pts)\n")

        {output, _} ->
          IO.puts("  ❌ FAIL (0 pts)")
          IO.puts("  Error: #{String.slice(output, 0, 200)}\n")
      end
    end)
  end
end

# Run the tracker
ScoringTracker.start()
